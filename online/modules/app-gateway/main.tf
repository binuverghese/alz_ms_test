resource "azurerm_application_gateway" "example" {
  name                = var.app_gateway_name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku {
    name = "Standard_v2"
    tier = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway_ip_config"
    subnet_id = var.subnet_id
  }

  frontend_port {
    name = "frontend_port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend_ip_config"
    public_ip_address_id = var.public_ip_id
  }

  backend_address_pool {
    name         = "backend_pool"
    ip_addresses = ["10.0.0.4"]
  }

  backend_http_settings {
    name                  = "backend_http_settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = "listener_name"
    frontend_ip_configuration_name = "frontend_ip_config"
    frontend_port_name             = "frontend_port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "default_rule"
    rule_type                  = "Basic"
    http_listener_name         = "listener_name"
    backend_address_pool_name  = "backend_pool"
    backend_http_settings_name = "backend_http_settings"
  }

  tags = {
    environment = "dev"
  }
}
