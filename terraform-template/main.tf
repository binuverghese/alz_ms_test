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
  subnet_id           = module.subnet.subnet_id
}

module "nsg" {
  source              = "./modules/nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
  nsg_name            = var.nsg_name
  security_rules      = var.security_rules
}


module "vnet" {
  source              = "./modules/vnet"
  name                = var.vnet_name  
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space_vnet1
  dns_servers         = var.dns_servers
  enable_vm_protection = var.enable_vm_protection
}

module "subnet" {
  source              = "./modules/subnet"
  vnet_id             = module.vnet.vnet_id
  subnet_name         = var.subnet_name
  address_prefixes    = var.subnet_address_prefixes
  route_table_id      = module.route_table.route_table_id
  nsg_id              = module.nsg.nsg_id
  resource_group_name = var.resource_group_name  
  vnet_name           = var.vnet_name 
  create_nsg        = true    
  create_route_table = true
}

