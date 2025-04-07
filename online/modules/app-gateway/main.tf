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

  gateway_ip_configurations = {
    ipconfig = {
      name      = "appgw-ipconfig"
      subnet_id = var.appgw_subnet_id
    }
  }

  frontend_ip_configurations = {
    feconfig = {
      name                 = "appgw-fe-ip"
      public_ip_address_id = var.public_ip_address_id
    }
  }

  frontend_ports = {
    port80 = {
      name = "port-80"
      port = 80
    }
  }

  backend_address_pools = {
    pool1 = {
      name = "backendpool1"
      backend_addresses = [
        { ip_address = "10.1.1.4" },
        { ip_address = "10.1.1.5" }
      ]
    }
  }

  backend_http_settings_collection = {
    http1 = {
      name                  = "http-settings"
      port                  = 80
      protocol              = "Http"
      cookie_based_affinity = "Disabled"
    }
  }

  http_listeners = {
    listener1 = {
      name                           = "listener-80"
      frontend_ip_configuration_name = "appgw-fe-ip"
      frontend_port_name             = "port-80"
      protocol                       = "Http"
    }
  }

  request_routing_rules = {
    rule1 = {
      name                       = "rule1"
      rule_type                  = "Basic"
      http_listener_name         = "listener-80"
      backend_address_pool_name  = "backendpool1"
      backend_http_settings_name = "http-settings"
    }
  }
}
