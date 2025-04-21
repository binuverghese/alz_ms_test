module "rg_main" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  name     = var.resource_group_name
  location = var.location
}

module "nsg" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "~> 0.1"

  name                = var.nsg_name
  location            = var.location
  resource_group_name = module.rg_main.name
  
  security_rules = {
    for idx, rule in var.security_rules : rule.name => {
      name                       = rule.name
      priority                   = rule.priority
      direction                  = rule.direction
      access                     = rule.access
      protocol                   = rule.protocol
      source_port_range          = rule.source_port_range
      destination_port_range     = rule.destination_port_range
      source_address_prefix      = rule.source_address_prefix
      destination_address_prefix = rule.destination_address_prefix
    }
  }

  depends_on = [module.rg_main]
}

# Virtual network without subnets
module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.1"

  name                = var.vnet_name
  location            = var.location
  resource_group_name = module.rg_main.name
  address_space       = var.address_space_vnet1
  
  enable_vm_protection = var.enable_vm_protection
  
  encryption = {
    enabled     = var.encryption
    enforcement = var.encryption_enforcement
    type        = var.encryption_type
  }
  
  flow_timeout_in_minutes = var.flow_timeout_in_minutes
  
  # Empty subnets - we'll create separately
  subnets = {}
}

# Create subnet separately
resource "azurerm_subnet" "main" {
  name                 = var.subnet_name
  resource_group_name  = module.rg_main.name
  virtual_network_name = module.vnet.name
  address_prefixes     = var.subnet_address_prefixes
  
  #private_link_endpoint_network_policies_enabled = true
}

# Explicit subnet-NSG association
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = module.nsg.resource.id
  
  depends_on = [azurerm_subnet.main, module.nsg]
}

# Create resource group for Application Gateway
module "rg_appgw" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  name     = "${var.resource_group_name}-appgw"
  location = var.location
}

# Create public IP for Application Gateway
resource "azurerm_public_ip" "appgw_pip" {
  name                = "pip-appgw"
  resource_group_name = module.rg_appgw.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]  # Making it zone-redundant to match the Application Gateway zones
}

# Create subnet for Application Gateway
resource "azurerm_subnet" "appgw_subnet" {
  name                 = "snet-appgw"
  resource_group_name  = module.rg_main.name
  virtual_network_name = module.vnet.name
  address_prefixes     = ["10.1.0.16/28"] # Using a subnet within the VNET's 10.1.0.0/24 range
}

module "application_gateway" {
  source             = "Azure/avm-res-network-applicationgateway/azurerm"
  version            = "0.3.0"

  # Resource group and location (use existing modules)
  resource_group_name = module.rg_appgw.name
  location            = var.location
  
  # Use existing public IP that you already created
  public_ip_resource_id = azurerm_public_ip.appgw_pip.id
  create_public_ip      = false

  # Provide Application gateway name 
  name = var.app_gateway_name

  # Frontend IP configuration names
  frontend_ip_configuration_public_name = "public-ip-config"

  frontend_ip_configuration_private = {
    name                          = "private-ip-config"
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.0.20" # Using an IP from the AppGW subnet CIDR range
    subnet_id                     = azurerm_subnet.appgw_subnet.id
  }

  # Gateway IP configuration
  gateway_ip_configuration = {
    name      = "appGatewayIpConfig"
    subnet_id = azurerm_subnet.appgw_subnet.id
  }

  tags = {
    environment = "development"
  }

  # WAF: Using Standard_v2 for better performance and autoscaling capabilities
  sku = {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }
  
  # Configure availability zones to match the public IP
  zones = ["1", "2", "3"]

  # Enable autoscaling for better handling of traffic spikes
  autoscale_configuration = {
    min_capacity = 2
    max_capacity = 5
  }

  # Frontend port configuration
  frontend_ports = {
    port_80 = {
      name = "port_80"
      port = 80
    }
    port_443 = {
      name = "port_443"
      port = 443
    }
  }

  # Backend address pool configuration
  backend_address_pools = {
    default = {
      name         = "default-backend-pool"
      ip_addresses = []
      fqdns        = []
    }
  }

  # Backend HTTP settings
  backend_http_settings = {
    default = {
      name                  = "default-http-settings"
      port                  = 80
      protocol              = "Http"
      cookie_based_affinity = "Disabled"
      path                  = "/"
      request_timeout       = 30
    }
  }

  # HTTP listeners
  http_listeners = {
    default = {
      name                           = "default-listener"
      frontend_ip_configuration_name = "public-ip-config"
      frontend_port_name             = "port_80"
      protocol                       = "Http"
    }
  }

  # Request routing rules
  request_routing_rules = {
    default = {
      name                       = "default-rule"
      rule_type                  = "Basic"
      http_listener_name         = "default-listener"
      backend_address_pool_name  = "default-backend-pool"
      backend_http_settings_name = "default-http-settings"
      priority                   = 100
    }
  }

  depends_on = [
    module.vnet,
    azurerm_subnet.appgw_subnet
  ]
}
