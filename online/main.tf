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
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
  subnets = {
    AzureFirewallSubnet = {
      name             = "AzureFirewallSubnet"
      address_prefixes = ["10.0.0.0/24"]
    }
    AppGatewaySubnet = {
      name             = "AppGatewaySubnet"
      address_prefixes = ["10.0.3.0/24"]
    }
  }
}

module "app_gateway" {
  source  = "Azure/avm-res-network-applicationgateway/azurerm"
  version = "~> 0.3"

  name                = "appgw-dev-001"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku = {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration = [
    {
      name      = "appgw-ipconfig"
      subnet_id = module.hub_vnet.subnets["AppGatewaySubnet"].resource_id
    }
  ]

  frontend_ip_configuration = [
    {
      name                 = "appgw-fe-ip"
      public_ip_address_id = azurerm_public_ip.appgw_public_ip.id
    }
  ]

  frontend_ports = [
    {
      name = "port-80"
      port = 80
    }
  ]

  backend_address_pools = [
    {
      name = "backendpool1"
      backend_addresses = [
        { ip_address = "10.1.1.4" },
        { ip_address = "10.1.1.5" }
      ]
    }
  ]

  backend_http_settings = [
    {
      name                  = "http-settings"
      port                  = 80
      protocol              = "Http"
      cookie_based_affinity = "Disabled"
    }
  ]

  http_listeners = [
    {
      name                           = "listener-80"
      frontend_ip_configuration_name = "appgw-fe-ip"
      frontend_port_name             = "port-80"
      protocol                       = "Http"
    }
  ]

  request_routing_rules = [
    {
      name                       = "rule1"
      rule_type                  = "Basic"
      http_listener_name         = "listener-80"
      backend_address_pool_name  = "backendpool1"
      backend_http_settings_name = "http-settings"
    }
  ]
}

resource "azurerm_public_ip" "appgw_public_ip" {
  name                = "appgw-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [1, 2, 3]
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-dev-002"
  location = "Canada Central"
}

resource "azurerm_virtual_network" "vnet1" {
  name                = "hub-vnet" 
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

module "dns_vnet" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  version             = "~> 0.2"
  name                = "dns-vnet"
  enable_telemetry    = false
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
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


# Firewall Public IP
resource "azurerm_public_ip" "firewall_pip" {
  name                = var.firewall_pip_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [1, 2, 3]
}

# Firewall Policy
module "fw_policy" {
  source              = "Azure/avm-res-network-firewallpolicy/azurerm"
  name                = var.firewall_policy_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

output "fw_policy_id" {
  value = module.fw_policy.resource_id
}

# Firewall
module "firewall" {
  source              = "Azure/avm-res-network-azurefirewall/azurerm"
  name                = var.firewall_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
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
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
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
  location            = azurerm_resource_group.rg.location
  name                = "bastion-public-ip"
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  zones               = [1, 2, 3]
}

# Bastion Host
module "azure_bastion" {
  source              = "Azure/avm-res-network-bastionhost/azurerm"
  enable_telemetry    = true
  name                = module.naming.bastion_host.name_unique
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
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
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = module.bastion_vnet.name
  remote_virtual_network_id    = module.hub_vnet.resource_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
}

resource "azurerm_virtual_network_peering" "hub_to_bastion" {
  name                         = "hub-to-bastion"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = module.hub_vnet.name
  remote_virtual_network_id    = module.bastion_vnet.resource_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  use_remote_gateways          = false
}

# VNet Peering - DNS Resolver VNet to Hub VNet
resource "azurerm_virtual_network_peering" "dns_to_hub" {
  name                         = "dns-to-hub"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = module.dns_vnet.name
  remote_virtual_network_id    = module.hub_vnet.resource_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
}

resource "azurerm_virtual_network_peering" "hub_to_dns" {
  name                         = "hub-to-dns"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = module.hub_vnet.name
  remote_virtual_network_id    = module.dns_vnet.resource_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
  use_remote_gateways          = false
}
