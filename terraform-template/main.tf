provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
  client_id       = var.client_id
}

provider "azapi" {}

module "rg" {
  source = "./modules/resource_group"
  location = var.location
  resource_group_name = var.resource_group_name
}

module "route_table" {
  source = "./modules/route_table"
  location = var.location
  resource_group_name = var.resource_group_name
  route_table_name = var.route_table_name
  routes = var.routes
}

module "nsg" {
  source = "./modules/nsg"
  location = var.location
  resource_group_name = var.resource_group_name
  nsg_name = var.nsg_name
}

module "vnet" {
  source = "./modules/vnet"
  location = var.location
  resource_group_name = var.resource_group_name
  vnet_name = var.vnet_name
  address_space_vnet1 = var.address_space_vnet1
  dns_servers = var.dns_servers
  enable_vm_protection = var.enable_vm_protection
}

module "subnet" {
  source = "./modules/subnet"
  subnet_name = var.subnet_name
  address_prefixes = var.subnet_address_prefixes
  virtual_network_id = module.vnet.vnet_id
  route_table_id = module.route_table.route_table_id
  nsg_id = module.nsg.nsg_id
}

