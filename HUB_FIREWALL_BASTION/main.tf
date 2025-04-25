terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.116.0, < 5.0.0"  # Using 3.116.0 to satisfy the strictest version constraint
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
    modtm = {
      source  = "Azure/modtm"
      version = "~> 0.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"  # This satisfies all ~> 3.5 constraints
    }
    azapi = {
      source  = "azure/azapi"  # Lowercase 'azure' instead of 'Azure'
      version = ">= 1.13.0, < 2.0.0"  # Constrain to 1.x versions only
    }
  }
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azapi" {}
provider "modtm" {}
provider "random" {}
provider "http" {}

# Resource Groups - Creating the 4 resource groups
module "rg_hub" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  name     = local.hub_rg_name
  location = var.location
  tags     = var.tags
}

module "rg_firewall" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  name     = local.firewall_rg_name
  location = var.location
  tags     = var.tags
}

module "rg_dns" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  name     = local.dns_rg_name
  location = var.location
  tags     = var.tags
}

module "rg_bastion" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  name     = local.bastion_rg_name
  location = var.location
  tags     = var.tags
}

# Hub NSG and Route Table
module "hub_nsg" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.4.0"

  name                = local.hub_nsg_name
  location            = var.location
  resource_group_name = module.rg_hub.name

  security_rules = { for rule in var.security_rules : rule.name => rule }

  tags       = var.tags
  depends_on = [module.rg_hub]
}

module "hub_route_table" {
  source  = "Azure/avm-res-network-routetable/azurerm"
  version = "0.4.1"
  
  name                = local.hub_route_table_name
  resource_group_name = module.rg_hub.name
  routes              = { for idx, route in var.routes : route.name => route }
  location            = var.location
}

# DNS/Bastion NSG
module "dns_bastion_nsg" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "0.4.0"

  name                = local.dns_bastion_nsg_name
  location            = var.location
  resource_group_name = module.rg_hub.name

  security_rules = { for rule in var.security_rules : rule.name => rule }

  tags       = var.tags
  depends_on = [module.rg_hub]
}

# Hub VNET with Firewall Subnet and Express Gateway
module "hub_vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.5.0"

  name                = local.hub_vnet_name
  location            = var.location
  resource_group_name = module.rg_hub.name
  address_space       = var.hub_vnet_address_space

  # Defining subnets within the hub VNET
  subnets = {
    # Azure Firewall Subnet - must use this specific name
    "AzureFirewallSubnet" = {
      name                                      = "AzureFirewallSubnet"
      address_prefixes                          = var.firewall_subnet_address_prefixes
      private_endpoint_network_policies_enabled = false
      # No NSG allowed on Firewall subnet
    }

    # Express Gateway Subnet - must use this specific name
    "GatewaySubnet" = {
      name                                      = "GatewaySubnet"
      address_prefixes                          = var.express_gateway_subnet_address_prefixes
      private_endpoint_network_policies_enabled = false
      # No NSG allowed on Gateway subnet
    }
  }

  tags = var.tags

  depends_on = [
    module.rg_hub,
    module.hub_nsg
  ]
}

# Firewall VNET with AzureFirewallSubnet
module "firewall_vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.5.0"

  name                = local.firewall_vnet_name
  location            = var.location
  resource_group_name = module.rg_firewall.name
  address_space       = var.firewall_vnet_address_space

  # Creating only the AzureFirewallSubnet in this VNET
  subnets = {
    # Azure Firewall Subnet - must use this specific name
    "AzureFirewallSubnet" = {
      name                                      = "AzureFirewallSubnet"
      address_prefixes                          = var.firewall_vnet_subnet_address_prefixes
      private_endpoint_network_policies_enabled = false
      # No NSG allowed on Firewall subnet
    }
  }

  tags = var.tags

  depends_on = [
    module.rg_firewall
  ]
}

# DNS/Bastion VNET
module "dns_bastion_vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.5.0"

  name                = local.dns_bastion_vnet_name
  location            = var.location
  resource_group_name = module.rg_hub.name
  address_space       = var.dns_bastion_vnet_address_space

  # Defining subnets for DNS Resolver and Bastion
  subnets = {
    # DNS Resolver Inbound Endpoint Subnet
    "InboundEndpointSubnet" = {
      name             = "InboundEndpointSubnet"
      address_prefixes = var.dns_resolver_inbound_subnet_address_prefixes
      delegation = [
        {
          name = "Microsoft.Network.dnsResolvers"
          service_delegation = {
            name    = "Microsoft.Network/dnsResolvers"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
          }
        }
      ]
    }

    # DNS Resolver Outbound Endpoint Subnet
    "OutboundEndpointSubnet" = {
      name             = "OutboundEndpointSubnet"
      address_prefixes = var.dns_resolver_outbound_subnet_address_prefixes
      delegation = [
        {
          name = "Microsoft.Network.dnsResolvers"
          service_delegation = {
            name    = "Microsoft.Network/dnsResolvers"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
          }
        }
      ]
    }

    # Azure Bastion Subnet - must use this specific name
    "AzureBastionSubnet" = {
      name                                      = "AzureBastionSubnet"
      address_prefixes                          = var.bastion_subnet_address_prefixes
      private_endpoint_network_policies_enabled = false
      # No NSG allowed on Bastion subnet
    }
  }

  tags = var.tags

  depends_on = [
    module.rg_hub,
    module.dns_bastion_nsg
  ]
}

# VNET Peering (Hub to DNS/Bastion)
module "hub_to_dns_bastion_peering" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm//modules/peering"
  version = "0.5.0"

  virtual_network = {
    resource_id = module.hub_vnet.resource.id
  }
  remote_virtual_network = {
    resource_id = module.dns_bastion_vnet.resource.id
  }
  name                         = local.hub_to_dns_peering_name
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
  
  depends_on = [
    module.hub_vnet,
    module.dns_bastion_vnet
  ]
}

# VNET Peering (DNS/Bastion to Hub)
module "dns_bastion_to_hub_peering" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm//modules/peering"
  version = "0.5.0"

  virtual_network = {
    resource_id = module.dns_bastion_vnet.resource.id
  }
  remote_virtual_network = {
    resource_id = module.hub_vnet.resource.id
  }
  name                         = local.dns_to_hub_peering_name
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false  # Changed from true to false since Hub VNET has no gateways
  
  depends_on = [
    module.hub_vnet,
    module.dns_bastion_vnet,
    module.hub_to_dns_bastion_peering
  ]
}

# VNET Peering (Firewall to Hub)
module "firewall_to_hub_peering" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm//modules/peering"
  version = "0.5.0"

  virtual_network = {
    resource_id = module.firewall_vnet.resource.id
  }
  remote_virtual_network = {
    resource_id = module.hub_vnet.resource.id
  }
  name                         = local.firewall_to_hub_peering_name
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
  
  depends_on = [
    module.firewall_vnet,
    module.hub_vnet
  ]
}

# VNET Peering (Hub to Firewall)
module "hub_to_firewall_peering" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm//modules/peering"
  version = "0.5.0"

  virtual_network = {
    resource_id = module.hub_vnet.resource.id
  }
  remote_virtual_network = {
    resource_id = module.firewall_vnet.resource.id
  }
  name                         = local.hub_to_firewall_peering_name
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
  
  depends_on = [
    module.hub_vnet,
    module.firewall_vnet
  ]
}

# Firewall Public IP
module "firewall_pip" {
  source  = "Azure/avm-res-network-publicipaddress/azurerm"
  version = "0.1.2"

  name                = "${local.firewall_name}-pip"
  location            = var.location
  resource_group_name = module.rg_firewall.name  # Using firewall resource group
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [1, 2, 3]

  tags = var.tags
}

# Firewall Policy
module "firewall_policy" {
  source  = "Azure/avm-res-network-firewallpolicy/azurerm"
  version = "0.3.3"

  name                = local.firewall_policy_name
  location            = var.location
  resource_group_name = module.rg_firewall.name  # Using firewall resource group
  firewall_policy_sku = var.firewall_policy_sku_tier

  firewall_policy_dns = {
    servers        = var.dns_servers
    proxy_enabled  = true
  }

  tags = var.tags

  depends_on = [module.rg_firewall]
}

# Azure Firewall
module "firewall" {
  source  = "Azure/avm-res-network-azurefirewall/azurerm"
  version = "0.3.0"

  name                = local.firewall_name
  resource_group_name = module.rg_firewall.name  # Using firewall resource group
  location            = var.location

  firewall_sku_name = "AZFW_VNet"
  firewall_sku_tier = var.firewall_sku_tier

  firewall_policy_id = module.firewall_policy.resource.id

  # IP Configuration - using the new firewall VNET
  firewall_ip_configuration = [{
    name                 = "fw-ipconfig"
    public_ip_address_id = module.firewall_pip.public_ip_id
    subnet_id            = "${module.firewall_vnet.resource.id}/subnets/AzureFirewallSubnet"  # Using new firewall VNET
  }]

  tags = var.tags

  depends_on = [
    module.rg_firewall,
    module.firewall_vnet,
    module.firewall_policy,
    module.firewall_pip
  ]
}

# DNS Resolver
module "private_resolver" {
  source  = "Azure/avm-res-network-dnsresolver/azurerm"
  version = "0.7.2"
  
  name                        = local.dns_resolver_name
  resource_group_name         = module.rg_dns.name
  location                    = var.location
  virtual_network_resource_id = module.dns_bastion_vnet.resource.id
  
  # Inbound endpoint in the DNS/Bastion VNET
  inbound_endpoints = {
    "inbound1" = {
      name        = "inbound1"
      subnet_id   = module.dns_bastion_vnet.subnets["InboundEndpointSubnet"].resource_id
      subnet_name = "InboundEndpointSubnet"
    }
  }
  
  # Outbound endpoint in the DNS/Bastion VNET
  outbound_endpoints = {
    "outbound1" = {
      name        = "outbound1"
      subnet_id   = module.dns_bastion_vnet.subnets["OutboundEndpointSubnet"].resource_id
      subnet_name = "OutboundEndpointSubnet"
      # No forwarding ruleset needed initially
    }
  }
  
  enable_telemetry = var.enable_telemetry
  
  depends_on = [
    module.rg_dns,
    module.dns_bastion_vnet
  ]
}

# Bastion Public IP
module "bastion_pip" {
  source  = "Azure/avm-res-network-publicipaddress/azurerm"
  version = "0.1.2"
  
  name                = "${local.bastion_name}-pip"
  location            = var.location
  resource_group_name = module.rg_bastion.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [1, 2, 3]
  
  tags = var.tags
}

# Azure Bastion - Using AVM Module version 0.6.0 which is compatible with current azapi constraints
module "bastion" {
  source  = "Azure/avm-res-network-bastionhost/azurerm"
  version = "0.6.0"
  
  name                = local.bastion_name
  resource_group_name = module.rg_bastion.name
  location            = var.location
  sku                 = var.bastion_sku
  
  ip_configuration = {
    name                 = "bastion-ipconfig"
    subnet_id            = module.dns_bastion_vnet.subnets["AzureBastionSubnet"].resource_id
    public_ip_address_id = module.bastion_pip.public_ip_id
    create_public_ip     = false
  }
  
  # Additional Bastion features
  copy_paste_enabled     = true
  file_copy_enabled      = true
  ip_connect_enabled     = true
  shareable_link_enabled = true
  tunneling_enabled      = true
  
  tags = var.tags
  
  depends_on = [
    module.rg_bastion,
    module.dns_bastion_vnet,
    module.bastion_pip
  ]
}
