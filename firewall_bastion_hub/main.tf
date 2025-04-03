terraform {
  required_version = ">= 1.9, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.116.0, < 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "1e437fdf-bd78-431d-ba95-1498f0e84c10"
}

# Providers with Aliases
provider "azurerm" {
  alias           = "hub"
  subscription_id = "1e437fdf-bd78-431d-ba95-1498f0e84c10"
  features {}
}

provider "azurerm" {
  alias           = "spoke"
  subscription_id = "1e437fdf-bd78-431d-ba95-1498f0e84c10"
  features {}
}

# Resource Group
resource "azurerm_resource_group" "this" {
  location = "Canada Central"
  name     = "rg-dev-001"
}

# Naming module
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
}

# Hub VNet
module "hub_vnet" {
  source = "Azure/avm-res-network-virtualnetwork/azurerm"
  providers = {
    azurerm = azurerm.hub
  }
  name                = "hub-vnet"
  enable_telemetry    = false
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  address_space       = ["10.0.0.0/24"]
  subnets = {
    AzureFirewallSubnet = {
      name             = "AzureFirewallSubnet"
      address_prefixes = ["10.0.0.0/24"]
    }
  }
}
resource "azurerm_subnet" "inbound" {
  name                 = "InboundEndpoint"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.0.0.0/24"]  
}

resource "azurerm_subnet" "outbound" {
  name                 = "OutboundEndpoint"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.1.0.0/24"]  
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-dev-001"  
  location = "Canada Central"  
}

resource "azurerm_virtual_network" "vnet1" {
  name                = "hub-vnet"  # Replace with your desired virtual network name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.0.0.0/16"]  
}

resource "azurerm_virtual_network" "vnet2" {
  name                = "spoke-vnet"  
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.1.0.0/16"]  
}
# DNS Resolver VNet
module "dns_vnet" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  version             = "~> 0.2"
  name                = "dns-vnet"
  enable_telemetry    = false
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  address_space       = ["10.0.2.0/24"]
  subnets = {
    InboundEndpoint = {
      name             = "InboundEndpoint"
      address_prefixes = ["10.0.2.0/28"]
    }
    OutboundEndpoint = {
      name             = "OutboundEndpoint"
      address_prefixes = ["10.0.2.16/28"]
    }
  }
}

module "private_resolver" {
  source  = "Azure/avm-res-network-dnsresolver/azurerm"
  resource_group_name         = azurerm_resource_group.rg.name
  name                        = "resolver"
  virtual_network_resource_id = azurerm_virtual_network.vnet1.id
  location                    = "Canada Central"

  inbound_endpoints = {
     "inbound1" = {
       name        = "inbound1"
       subnet_name = azurerm_subnet.inbound.name  # Reference the created inbound subnet
     }
   }

   outbound_endpoints = {
     "outbound1" = {
       name        = "outbound1"
       subnet_name = azurerm_subnet.outbound.name  # Reference the created outbound subnet
       forwarding_ruleset = {
         "ruleset1" = {
           name = "ruleset1"
           additional_virtual_network_links = {
             "vnet2" = {
               vnet_id = azurerm_virtual_network.vnet2.id
               metadata = {
                 "type" = "spoke"
                 "env"  = "dev"
               }
             }
           }
           rules = {
             "rule1" = {
               name        = "rule1"
               domain_name = "example.com."
               state       = "Enabled"
               destination_ip_addresses = {
                 "10.1.1.1" = "53"
                 "10.1.1.2" = "53"
               }
             }
           }
         }
       }
     }
   }
}

# Firewall Public IP
resource "azurerm_public_ip" "firewall_pip" {
  name                = var.firewall_pip_name
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [1, 2, 3]
}

# Firewall Policy
module "fw_policy" {
  source              = "Azure/avm-res-network-firewallpolicy/azurerm"
  name                = var.firewall_policy_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
}

output "fw_policy_id" {
  value = module.fw_policy.resource_id
}

# Firewall
module "firewall" {
  source              = "Azure/avm-res-network-azurefirewall/azurerm"
  name                = var.firewall_name
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  firewall_sku_tier   = var.firewall_sku_tier
  firewall_sku_name   = var.firewall_sku_name
  firewall_policy_id  = module.fw_policy.resource_id

  firewall_ip_configuration = [
    {
      name                 = var.firewall_ipconfig_name
      subnet_id            = module.hub_vnet.subnets["AzureFirewallSubnet"].resource_id
      public_ip_address_id = azurerm_public_ip.firewall_pip.id
    }
  ]
}

# Bastion VNet
module "bastion_vnet" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  version             = "~> 0.2"
  name                = "bastion-vnet"
  enable_telemetry    = false
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  address_space       = ["10.0.1.0/24"]
  subnets = {
    AzureBastionSubnet = {
      name             = "AzureBastionSubnet"
      address_prefixes = ["10.0.1.0/24"]
    }
  }
}

# Bastion Public IP
resource "azurerm_public_ip" "bastion_ip" {
  allocation_method   = "Static"
  location            = azurerm_resource_group.this.location
  name                = "bastion-public-ip"
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "Standard"
  zones               = [1, 2, 3]
}

# Bastion Host
module "azure_bastion" {
  source              = "Azure/avm-res-network-bastionhost/azurerm"
  enable_telemetry    = true
  name                = module.naming.bastion_host.name_unique
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  copy_paste_enabled  = true
  file_copy_enabled   = false
  sku                 = "Standard"
  ip_configuration = {
    name                 = "bastion-ipconfig"
    subnet_id            = module.bastion_vnet.subnets["AzureBastionSubnet"].resource_id
    public_ip_address_id = azurerm_public_ip.bastion_ip.id
    create_public_ip     = false
  }
  ip_connect_enabled     = true
  scale_units            = 4
  shareable_link_enabled = true
  tunneling_enabled      = true
  kerberos_enabled       = true
  tags = {
    environment = "development"
  }
}


# VNet Peering - Bastion VNet to Hub VNet
resource "azurerm_virtual_network_peering" "bastion_to_hub" {
  name                         = "bastion-to-hub"
  resource_group_name          = azurerm_resource_group.this.name
  virtual_network_name         = module.bastion_vnet.name
  remote_virtual_network_id    = module.hub_vnet.resource_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
}

resource "azurerm_virtual_network_peering" "hub_to_bastion" {
  name                         = "hub-to-bastion"
  resource_group_name          = azurerm_resource_group.this.name
  virtual_network_name         = module.hub_vnet.name
  remote_virtual_network_id    = module.bastion_vnet.resource_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = false
}

# VNet Peering - DNS Resolver VNet to Hub VNet
resource "azurerm_virtual_network_peering" "dns_to_hub" {
  name                         = "dns-to-hub"
  resource_group_name          = azurerm_resource_group.this.name
  virtual_network_name         = module.dns_vnet.name
  remote_virtual_network_id    = module.hub_vnet.resource_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
}

resource "azurerm_virtual_network_peering" "hub_to_dns" {
  name                         = "hub-to-dns"
  resource_group_name          = azurerm_resource_group.this.name
  virtual_network_name         = module.hub_vnet.name
  remote_virtual_network_id    = module.dns_vnet.resource_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  use_remote_gateways          = false
}
