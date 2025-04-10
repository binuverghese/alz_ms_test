# Provider configuration
provider "azurerm" {
  features {}
  subscription_id = "1e437fdf-bd78-431d-ba95-1498f0e84c10"
}

# Resource Groups
module "main_resource_group" {
  source  = "./modules/resource-group"
  name    = var.main_rg_name
  location = var.location
}

module "appgw_resource_group" {
  source  = "./modules/resource-group"
  name    = var.appgw_rg_name
  location = var.location
}

module "fw_policy_resource_group" {
  source  = "./modules/resource-group"
  name    = var.fw_policy_rg_name
  location = var.location
}

# Hub Virtual Network
module "hub_vnet" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  name                = var.hub_vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = module.main_resource_group.name
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

# Second VNet for Peering
module "spoke_vnet" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  name                = var.spoke_vnet_name
  address_space       = ["10.1.0.0/16"]
  location            = var.location
  resource_group_name = module.main_resource_group.name
  enable_telemetry    = false

  subnets = {
    Backend = {
      name             = "Backend"
      address_prefixes = ["10.1.1.0/24"]
    }
  }
}

# VNet Peering: Hub to Spoke
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "hub-to-spoke"
  resource_group_name       = module.main_resource_group.name
  virtual_network_name      = module.hub_vnet.name
  remote_virtual_network_id = module.spoke_vnet.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  use_remote_gateways       = false
}

# VNet Peering: Spoke to Hub
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "spoke-to-hub"
  resource_group_name       = module.main_resource_group.name
  virtual_network_name      = module.spoke_vnet.name
  remote_virtual_network_id = module.hub_vnet.id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = false
  use_remote_gateways       = false
}

# Public IP for App Gateway
module "public_ip_appgw" {
  source              = "./modules/public-ip"
  name                = var.appgw_public_ip_name
  resource_group_name = module.appgw_resource_group.name
  location            = var.location
}

# Application Gateway
module "application_gateway" {
  source                   = "Azure/avm-res-network-applicationgateway/azurerm"
  resource_group_name      = module.appgw_resource_group.name
  location                 = var.location
  enable_telemetry         = var.enable_telemetry
  public_ip_resource_id    = module.public_ip_appgw.id
  create_public_ip         = false
  name                     = var.appgw_name

  frontend_ip_configuration_public_name = "public-ip-custom-name"

  frontend_ip_configuration_private = {
    name                          = "private-ip-custom-name"
    private_ip_address_allocation = "Static"
    private_ip_address            = "100.64.1.5"
  }

  gateway_ip_configuration = {
    name      = "appGatewayIpConfig"
    subnet_id = module.hub_vnet.subnet_ids["AppGatewaySubnet"]
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
    pool1 = {
      name         = "app-Gateway-Backend-Pool-80"
      ip_addresses = ["100.64.2.6", "100.64.2.5"]
    }
    pool2 = {
      name  = "app-Gateway-Backend-Pool-81"
      fqdns = ["example1.com", "example2.com"]
    }
  }

  backend_http_settings = {
    setting1 = {
      name                  = "http-setting-80"
      port                  = 80
      protocol              = "Http"
      cookie_based_affinity = "Disabled"
      path                  = "/"
      request_timeout       = 30
      connection_draining = {
        enable_connection_draining = true
        drain_timeout_sec          = 300
      }
    }
    setting2 = {
      name                  = "http-setting-81"
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
    listener1 = {
      name                           = "listener-80"
      frontend_ip_configuration_name = "public-ip-custom-name"
      frontend_port_name             = "port_80"
    }
    listener2 = {
      name                           = "listener-81"
      frontend_ip_configuration_name = "private-ip-custom-name"
      frontend_port_name             = "port_81"
    }
  }

  request_routing_rules = {
    rule1 = {
      name                       = "rule-1"
      rule_type                  = "Basic"
      http_listener_name         = "listener-80"
      backend_address_pool_name  = "app-Gateway-Backend-Pool-80"
      backend_http_settings_name = "http-setting-80"
      priority                   = 100
    }
    rule2 = {
      name                       = "rule-2"
      rule_type                  = "Basic"
      http_listener_name         = "listener-81"
      backend_address_pool_name  = "app-Gateway-Backend-Pool-81"
      backend_http_settings_name = "http-setting-81"
      priority                   = 101
    }
  }
}

# Firewall Policy (Referenced by Firewall Module)
data "azurerm_firewall_policy" "existing" {
  name                = var.firewall_policy_name
  resource_group_name = module.fw_policy_resource_group.name
}

# Firewall
module "firewall" {
  source                  = "./modules/firewall"
  name                    = var.firewall_name
  resource_group_name     = module.main_resource_group.name
  location                = var.location
  firewall_sku_name       = var.firewall_sku_name
  firewall_sku_tier       = var.firewall_sku_tier
  firewall_policy_id      = data.azurerm_firewall_policy.existing.id
  firewall_ipconfig_name  = var.firewall_ipconfig_name
  subnet_id               = module.hub_vnet.subnet_ids["AzureFirewallSubnet"]
  public_ip_address_id    = module.firewall_pip.id
}

# Firewall Public IP
module "firewall_pip" {
  source              = "./modules/public-ip"
  name                = var.firewall_pip_name
  resource_group_name = module.main_resource_group.name
  location            = var.location
}
