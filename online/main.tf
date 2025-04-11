terraform {
  required_version = ">= 1.3.0, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0, < 5.0.0"
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

# Resource Group Modules
module "resource_group_main" {
  source  = "./modules/resource-group"
  name    = var.main_rg_name
  location = var.location
}

module "resource_group_appgw" {
  source  = "./modules/resource-group"
  name    = var.appgw_rg_name
  location = var.location
}

module "resource_group_firewall_policy" {
  source  = "./modules/resource-group"
  name    = var.firewall_policy_rg_name
  location = var.location
}

# VNet Modules
module "vnet_hub" {
  source              = "./modules/vnet"
  name                = var.hub_vnet_name
  address_space       = var.hub_vnet_address_space
  location            = var.location
  resource_group_name = module.resource_group_main.name
  
  subnets = [
    {
      name           = "AzureFirewallSubnet"
      address_prefix = "10.0.0.0/24"
    },
    {
      name           = "AppGatewaySubnet"
      address_prefix = "10.0.3.0/24"
    },
    {
      name           = "DNSResolverInbound"
      address_prefix = "10.0.4.0/28"
    },
    {
      name           = "DNSResolverOutbound"
      address_prefix = "10.0.5.0/28"
    }
  ]
}

module "vnet_other" {
  source              = "./modules/vnet"
  name                = var.other_vnet_name
  location            = var.location
  resource_group_name = module.resource_group_main.name
  address_space       = ["10.20.0.0/16"]

  subnets = [
    {
      name           = "default"
      address_prefix = "10.20.1.0/24"
    },
    {
      name           = "app"
      address_prefix = "10.20.2.0/24"
    }
  ]
}

# VNet Peering Modules
module "hub_to_other_peering" {
  source              = "./modules/vnet-peering"
  name                = "hub-to-other"
  resource_group_name = module.vnet_hub.resource_group_name
  vnet_name           = module.vnet_hub.name
  remote_vnet_id      = module.vnet_other.id
}

module "other_to_hub_peering" {
  source              = "./modules/vnet-peering"
  name                = "other-to-hub"
  resource_group_name = module.vnet_other.resource_group_name
  vnet_name           = module.vnet_other.name
  remote_vnet_id      = module.vnet_hub.id
}

# DNS Resolver Module

module "dns-resolver" {
source                      = "./modules/dns-resolver"
location                    = var.location
resource_group_name         = module.vnet_hub.resource_group_name
inbound_name                = var.inbound_name
outbound_name               = var.outbound_name
dns_resolver_ip             = var.dns_resolver_ip
inbound_subnet_id           = module.vnet_hub.subnet_ids["DNSResolverInbound"]
outbound_subnet_id          = module.vnet_hub.subnet_ids["DNSResolverOutbound"]
virtual_network_id          = module.vnet_hub.id
}




# Firewall Policy Module
module "firewall_policy" {
  source              = "./modules/firewall-policy"
  name                = var.firewall_policy_name
  resource_group_name = module.resource_group_firewall_policy.name
  location            = var.location
  policy_type         = "Standard"
}

# Firewall Module
module "firewall" {
  source              = "./modules/firewall"
  name                = "dev-firewall"
  location            = var.location
  resource_group_name = module.resource_group_main.name
  firewall_name       = "my-firewall"
  firewall_sku_name   = "AZFW_VNet"
  firewall_sku_tier   = "Standard"
  firewall_policy_id  = module.firewall_policy.id

  subnet_id           = module.vnet_hub.subnet_ids["AzureFirewallSubnet"]
  public_ip_id        = module.firewall_pip.id
}

# Public IP Module for Firewall
module "firewall_pip" {
  source              = "./modules/public-ip"
  name                = var.firewall_pip_name
  resource_group_name = module.resource_group_main.name
  location            = var.location
}

# Application Gateway Public IP Resource
resource "azurerm_public_ip" "appgw_public_ip" {
  name                = "appgw-pip"
  location            = var.location
  resource_group_name = module.resource_group_appgw.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Application Gateway Module
module "app_gateway" {
  source                  = "./modules/app-gateway"
  name                    = var.appgw_name
  location                = var.location
  resource_group_name     = module.resource_group_appgw.name
  app_gateway_name        = "my-app-gateway"
  sku_name                = "Standard_v2"
  sku_tier                = "Standard_v2"
  sku_capacity            = 2

  gateway_ip_config_name  = "appGatewayIpConfig"
  frontend_ip_config_name = "frontendIpConfig"

  public_ip_address_id    = module.appgw_pip.id

  frontend_port_name      = "port80"
  frontend_port           = 80

  subnet_id               = module.vnet_hub.subnet_ids["AppGatewaySubnet"]
  public_ip_id            = azurerm_public_ip.appgw_public_ip.id
}

# Public IP Module for Application Gateway
module "appgw_pip" {
  source              = "./modules/public-ip"
  name                = var.appgw_public_ip_name
  resource_group_name = module.resource_group_appgw.name
  location            = var.location
}
