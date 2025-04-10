provider "azurerm" {
  features {}
  subscription_id = "1e437fdf-bd78-431d-ba95-1498f0e84c10"
}



#variable "appgw_zones" {
 # type = list(string)
#}

module "resource_group" {
  source  = "./modules/resource-group"
  name    = var.main_rg_name
  location = var.location
}

module "appgw_resource_group" {
  source  = "./modules/resource-group"
  name    = var.appgw_rg_name
  location = var.location
}

#resource "azurerm_resource_group" "rg_appgw_dev" {
#  name     = var.appgw_rg_name
 # location = var.location
#}

module "hub_vnet" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  name                = "hub-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  #resource_group_name = var.resource_group_name
  resource_group_name = module.resource_group.name
  enable_telemetry    = false

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

module "networking" {
  source              = "./modules/networking"
  #resource_group_name = var.resource_group_name
  resource_group_name = module.resource_group.name
  location            = var.location
  virtual_network_name = module.hub_vnet.name 
  subnets             = {
    AzureFirewallSubnet = { address_prefixes = ["10.0.0.0/24"] }
    AppGatewaySubnet    = { address_prefixes = ["10.0.3.0/24"] }
  }
}

module "public_ip" {
  source              = "./modules/public-ip"
  name                = var.appgw_public_ip_name
  resource_group_name = module.appgw_resource_group.name
  location            = var.location
}

resource "azurerm_resource_group" "rg_group" {
  name     = var.main_rg_name
  location = var.location
}

resource "azurerm_public_ip" "public_ip" {
  name                = var.appgw_public_ip_name
  resource_group_name = azurerm_resource_group.rg_group.name
  location            = azurerm_resource_group.rg_group.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-name"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_group.name
  address_space       = ["10.0.0.0/16"]
}
# resource "azurerm_subnet" "appgw_subnet" {
#   name                 = "AppGatewaySubnet"
#   resource_group_name  = azurerm_resource_group.rg_group.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = ["10.0.1.0/24"]
#   depends_on           = [azurerm_virtual_network.vnet]
# }
resource "azurerm_subnet" "backend" {
  name                 = "backend"
  resource_group_name  = azurerm_resource_group.rg_group.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

module "application_gateway" {
  source              = "Azure/avm-res-network-applicationgateway/azurerm"
  #resource_group_name = azurerm_resource_group.rg_group.name
  resource_group_name = module.appgw_resource_group.name
  location            = azurerm_resource_group.rg_group.location
  enable_telemetry    = var.enable_telemetry
  public_ip_resource_id = azurerm_public_ip.public_ip.id
  create_public_ip      = false

  name = var.appgw_name

  frontend_ip_configuration_public_name = "public-ip-custom-name"

  frontend_ip_configuration_private = {
    name                          = "private-ip-custom-name"
    private_ip_address_allocation = "Static"
    private_ip_address            = "100.64.1.5"
  }

  gateway_ip_configuration = {
    name      = "appGatewayIpConfig"
    subnet_id = module.networking.appgw_subnet_id
  }

  tags = {
    environment = "dev"
    owner       = "application_gateway"
    project     = "AVM"
  }

  sku = {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 0
  }

  autoscale_configuration = {
    min_capacity = 1
    max_capacity = 2
  }

  frontend_ports = {
    port_1 = {
      name = "port_81"
      port = 81
    }
    port_2 = {
      name = "port_80"
      port = 80
    }
  }

  backend_address_pools = {
    appGatewayBackendPool_80 = {
      name         = "app-Gateway-Backend-Pool-80"
      ip_addresses = ["100.64.2.6", "100.64.2.5"]
    },
    appGatewayBackendPool_81 = {
      name  = "app-Gateway-Backend-Pool-81"
      fqdns = ["example1.com", "example2.com"]
    }
  }

  backend_http_settings = {
    appGatewayBackendHttpSettings_80 = {
      name                  = "app-Gateway-Backend-Http-Settings-80"
      port                  = 80
      protocol              = "Http"
      cookie_based_affinity = "Disabled"
      path                  = "/"
      request_timeout       = 30
      connection_draining = {
        enable_connection_draining = true
        drain_timeout_sec          = 300
      }
    },
    appGatewayBackendHttpSettings_81 = {
      name                  = "app-Gateway-Backend-Http-Settings-81"
      port                  = 81
      protocol              = "Http"
      cookie_based_affinity = "Disabled"
      path                  = "/"
      request_timeout       = 30
      connection_draining = {
        enable_connection_draining = true
        drain_timeout_sec          = 300
      }
    }
  }

  http_listeners = {
    appGatewayHttpListener_80 = {
      name                           = "app-Gateway-Http-Listener-80"
      frontend_ip_configuration_name = "public-ip-custom-name"
      host_name                      = null
      frontend_port_name             = "port_80"
    },
    appGatewayHttpListener_81 = {
      name                           = "app-Gateway-Http-Listener-81"
      frontend_ip_configuration_name = "private-ip-custom-name"
      host_name                      = null
      frontend_port_name             = "port_81"
    }
  }

  request_routing_rules = {
    routing-rule-1 = {
      name                       = "rule-1"
      rule_type                  = "Basic"
      http_listener_name         = "app-Gateway-Http-Listener-80"
      backend_address_pool_name  = "app-Gateway-Backend-Pool-80"
      backend_http_settings_name = "app-Gateway-Backend-Http-Settings-80"
      priority                   = 100
    },
    routing-rule-2 = {
      name                       = "rule-2"
      rule_type                  = "Basic"
      http_listener_name         = "app-Gateway-Http-Listener-81"
      backend_address_pool_name  = "app-Gateway-Backend-Pool-81"
      backend_http_settings_name = "app-Gateway-Backend-Http-Settings-81"
      priority                   = 101
    }
  }

 # zones = var.appgw_zones
}

# Data source to fetch an existing Azure Firewall Policy by name and resource group
# data "azurerm_firewall_policy" "example" {
#   name                = "testrgdev002policy"  # Update with your policy name
#   resource_group_name = "rg-dev-002"  # Update with your resource group
# }

module "firewall" {
  source                  = "./modules/firewall"
  name                    = var.firewall_name
  resource_group_name     = module.resource_group.name
  location                = var.location
  firewall_sku_name       = var.firewall_sku_name
  firewall_sku_tier       = var.firewall_sku_tier
  #firewall_policy_id      = var.firewall_policy_id
  firewall_policy_id  = "/subscriptions/1e437fdf-bd78-431d-ba95-1498f0e84c10/resourceGroups/rg-dev-002/providers/Microsoft.Network/firewallPolicies/testrgdev002policy"

  firewall_ipconfig_name  = var.firewall_ipconfig_name
  #subnet_id               = module.networking.subnets["FirewallSubnet"].id
  subnet_id               = module.networking.subnet_ids["AzureFirewallSubnet"]
  public_ip_address_id    = module.firewall_pip.id
}

module "bastion" {
  source                  = "./modules/bastion"
  name                    = var.bastion_name
  resource_group_name     = module.resource_group.name
  location                = var.location
  ip_config_name          = var.bastion_ip_config_name
  subnet_id               = module.networking.subnet_ids["AppGatewaySubnet"]
  public_ip_address_id    = module.bastion_pip.id
  tags                    = var.tags
}

module "firewall_pip" {
  source              = "./modules/public-ip"
  name                = var.firewall_pip_name
  resource_group_name = module.resource_group.name
  location            = var.location
}



variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "enable_telemetry" {
  type    = bool
  default = true
}

variable "firewall_pip_name" {
  type = string
}

