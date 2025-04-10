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

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

module "hub_vnet" {
  source              = "./modules/vnet"
  name                = var.hub_vnet_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.hub_vnet_address_space
  subnets             = var.hub_vnet_subnets
}

module "dns_vnet" {
  source              = "./modules/vnet"
  name                = var.dns_vnet_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.dns_vnet_address_space
  subnets             = var.dns_vnet_subnets
}
# DNS Resolver Module
module "dns_resolver" {
  source                      = "./modules/dns_resolver"
  name                        = var.dns_resolver_name
  location                    = var.location
  resource_group_name         = azurerm_resource_group.rg.name
  virtual_network_resource_id = module.dns_vnet.vnet_id

  inbound_endpoints = {
    inbound1 = {
      name        = "inbound1"
      subnet_name = azurerm_subnet.inbound.name
    }
  }

  outbound_endpoints = {
    outbound1 = {
      name        = "outbound1"
      subnet_name = azurerm_subnet.outbound.name
    }
  }
}

module "bastion_vnet" {
  source              = "./modules/vnet"
  name                = var.bastion_vnet_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.bastion_vnet_address_space
  subnets             = var.bastion_vnet_subnets
}


module "firewall" {
  source              = "./modules/firewall"
  name                = var.firewall_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  firewall_ip         = var.firewall_ip
  firewall_policy_id  = module.firewall_policy.firewall_policy_id
  firewall_sku_tier   = var.firewall_sku_tier  
  firewall_sku_name   = var.firewall_sku_name
}

module "bastion" {
  source              = "./modules/bastion"
  name                = var.bastion_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  public_ip_id        = module.bastion_ip.public_ip_id
}

resource "azurerm_virtual_network_peering" "dns_to_hub" {
  name                         = "dns-to-hub"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = module.dns_vnet.name
  remote_virtual_network_id    = module.hub_vnet.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "hub_to_dns" {
  name                         = "hub-to-dns"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = module.hub_vnet.name
  remote_virtual_network_id    = module.dns_vnet.vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false
}
