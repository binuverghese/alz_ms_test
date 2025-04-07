# main.tf
module "resource_group" {
  source  = "./modules/resource-group"
  name    = var.rg_name
  location = var.location
}

module "appgw_resource_group" {
  source  = "./modules/resource-group"
  name    = var.appgw_rg_name
  location = var.location
}

module "networking" {
  source              = "./modules/networking"
  resource_group_name = module.resource_group.name
  location            = var.location
}

module "public_ip" {
  source              = "./modules/public-ip"
  name                = var.appgw_public_ip_name
  resource_group_name = module.appgw_resource_group.name
  location            = var.location
}

module "app_gateway" {
  source                  = "./modules/app-gateway"
  name                    = var.appgw_name
  resource_group_name     = module.appgw_resource_group.name
  location                = var.location
  public_ip_address_id    = module.public_ip.id
  appgw_subnet_id         = module.networking.appgw_subnet_id
}

module "firewall" {
  source                  = "./modules/firewall"
  name                    = var.firewall_name
  resource_group_name     = module.resource_group.name
  location                = var.location
  firewall_sku_name       = var.firewall_sku_name
  firewall_sku_tier       = var.firewall_sku_tier
  firewall_policy_id      = var.firewall_policy_id
  firewall_ipconfig_name  = var.firewall_ipconfig_name
  subnet_id               = module.networking.firewall_subnet_id
  public_ip_address_id    = module.firewall_pip.id
}

module "bastion" {
  source                  = "./modules/bastion"
  name                    = var.bastion_name
  resource_group_name     = module.resource_group.name
  location                = var.location
  ip_config_name          = var.bastion_ip_config_name
  subnet_id               = module.networking.bastion_subnet_id
  public_ip_address_id    = module.bastion_pip.id
  tags                    = var.tags
}
# variables.tf
variable "rg_name" {
  type = string
}

variable "appgw_rg_name" {
  type = string
}

variable "location" {
  type = string
  default = "Canada Central"
}

variable "appgw_name" {
  type = string
}

variable "appgw_public_ip_name" {
  type = string
}

# terraform.tfvars
rg_name             = "rg-dev-002"
appgw_rg_name       = "rg-appgw-dev-002"
location            = "Canada Central"
appgw_name          = "appgw-dev-001"
appgw_public_ip_name = "appgw-pip"

# modules/resource-group/main.tf
resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
}

output "name" {
  value = azurerm_resource_group.this.name
}

# modules/resource-group/variables.tf
variable "name" {
  type = string
}

variable "location" {
  type = string
}

# modules/public-ip/main.tf
resource "azurerm_public_ip" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [1, 2, 3]
}

output "id" {
  value = azurerm_public_ip.this.id
}

# modules/public-ip/variables.tf
variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

# modules/app-gateway/main.tf
module "app_gateway" {
  source  = "Azure/avm-res-network-applicationgateway/azurerm"
  version = "~> 0.3"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  sku = {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration = [{
    name      = "appgw-ipconfig"
    subnet_id = var.appgw_subnet_id
  }]

  frontend_ip_configuration = [{
    name                 = "appgw-fe-ip"
    public_ip_address_id = var.public_ip_address_id
  }]

  frontend_ports = [{
    name = "port-80"
    port = 80
  }]

  backend_address_pools = [{
    name = "backendpool1"
    backend_addresses = [
      { ip_address = "10.1.1.4" },
      { ip_address = "10.1.1.5" }
    ]
  }]

  backend_http_settings = [{
    name                  = "http-settings"
    port                  = 80
    protocol              = "Http"
    cookie_based_affinity = "Disabled"
  }]

  http_listeners = [{
    name                           = "listener-80"
    frontend_ip_configuration_name = "appgw-fe-ip"
    frontend_port_name             = "port-80"
    protocol                       = "Http"
  }]

  request_routing_rules = [{
    name                       = "rule1"
    rule_type                  = "Basic"
    http_listener_name         = "listener-80"
    backend_address_pool_name  = "backendpool1"
    backend_http_settings_name = "http-settings"
  }]
}

# modules/app-gateway/variables.tf
variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "public_ip_address_id" {
  type = string
}

variable "appgw_subnet_id" {
  type = string
}

# modules/networking/main.tf
module "hub_vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  name    = "hub-vnet"
  address_space = ["10.0.0.0/16"]
  location = var.location
  resource_group_name = var.resource_group_name
  enable_telemetry = false

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

output "appgw_subnet_id" {
  value = module.hub_vnet.subnets["AppGatewaySubnet"].resource_id
}

# modules/networking/variables.tf
variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}
