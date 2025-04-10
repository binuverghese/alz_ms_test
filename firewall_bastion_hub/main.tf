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
  #virtual_network_resource_id = module.dns_vnet.vnet_id
  virtual_network_id          = azurerm_virtual_network.vnet1.id 
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

  # Create AzureBastionSubnet specifically for Bastion
  subnets = merge(
    var.bastion_vnet_subnets,
    {
      AzureBastionSubnet = {
        name           = "AzureBastionSubnet"
        address_prefix = "10.0.1.0/24"  # Adjust subnet prefix as needed
      }
    }
  )
}


module "bastion" {
  source               = "./modules/bastion"
  name                 = var.bastion_name
  location             = var.location
  resource_group_name  = azurerm_resource_group.rg.name

  # DNS Name (public DNS name for Bastion)
  dns_name             = "${var.bastion_name}-${azurerm_resource_group.rg.location}.bastion.azure.com"  # Adjust DNS name as per your requirements

  # Subnet ID (Azure Bastion Subnet)
  subnet_id            = module.bastion_vnet.subnets["AzureBastionSubnet"].id  # Reference the correct subnet for Bastion

  ip_configuration = {
    name                 = "bastion-ipconfig"
    subnet_id            = module.bastion_vnet.subnets["AzureBastionSubnet"].id  # Ensure using the AzureBastionSubnet
    public_ip_address_id = module.bastion_ip.public_ip_id  # Reference the public IP created by the bastion_ip module
    create_public_ip     = false  # Set this to false as you are providing an external public IP
  }

  # Optional Bastion Host Configuration
  copy_paste_enabled   = true
  file_copy_enabled    = false
  ip_connect_enabled   = true
  scale_units          = 2
  tunneling_enabled    = true
  kerberos_enabled     = true

  tags = {
    environment = "development"
  }
}

# Create the Public IP for Bastion
resource "azurerm_public_ip" "bastion_ip" {
  name                = var.bastion_ip_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  domain_name_label   = "${var.bastion_name}-${azurerm_resource_group.rg.location}"
}

module "firewall" {
  source              = "./modules/firewall"
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
