# Local variables block for resource naming with concatenation
locals {
  # Resource names using naming convention concatenation
  #vnet_name               = "${var.bu}-${var.region_short}-${var.archetype}-${var.wl}-${var.env}-${var.wl_desc}-vnet"
  #resource_group_name     = "${var.bu}-${var.region_short}-${var.archetype}-${var.wl}-${var.env}-${var.wl_desc}-vnet-rg"
  vnet_name               = "${var.bu}-${var.region_short}-${var.archetype}-${var.wl}-${var.env}-vnet"
  resource_group_name     = "${var.bu}-${var.region_short}-${var.archetype}-${var.wl}-${var.env}-vnet-rg"
  appgw_resource_group    = "${var.bu}-${var.region_short}-${var.archetype}-${var.wl}-${var.env}-appgw-rg"
  # Using full naming convention for Application Gateway (you'll need to modify the module validation manually)
  appgw_name              = "${var.bu}-${var.region_short}-${var.archetype}-${var.wl}-${var.env}-appgateway-agw"
  appgw_pip_name          = "${var.bu}-${var.region_short}-${var.archetype}-${var.wl}-${var.env}-appgw-pip"
  nsg_name                = "${var.bu}-${var.region_short}-${var.archetype}-${var.wl}-${var.env}-workload-nsg"
  subnet_name             = "${var.bu}-${var.region_short}-${var.archetype}-${var.wl}-${var.env}-workload-snet"
  appgw_subnet_name       = "${var.bu}-${var.region_short}-${var.archetype}-${var.wl}-${var.env}-appgw-snet"
  peering_name            = "${local.vnet_name}-to-remote-vnet"
  reverse_peering_name    = "remote-vnet-to-${local.vnet_name}"
}

# Provider configuration for remote subscription
provider "azurerm" {
  alias           = "remote_subscription"
  subscription_id = var.remote_subscription_id
  tenant_id       = var.remote_tenant_id   # Use the explicit remote_tenant_id value
  client_id       = var.client_id
  
}

module "rg_main" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  name     = local.resource_group_name
  location = var.location
}

module "nsg" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "~> 0.1"

  name                = local.nsg_name
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

# Virtual network with subnets and NSG associations using AVM approach
module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.1"

  name                = local.vnet_name
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
  
  # Define subnets directly in the VNET module (AVM recommended approach)
  subnets = {
    appgw = {
      name             = local.appgw_subnet_name
      address_prefixes = ["10.100.0.64/27"]
      # Added NSG to the App Gateway subnet as requested
      network_security_group = {
        id = module.nsg.resource.id
      }
    }
  }
  
  # Add peering configuration using the native AVM VNET module peering feature
  peerings = var.remote_virtual_network_id != null ? {
    peer-to-remote-vnet = {
      name                              = local.peering_name
      remote_virtual_network_resource_id = var.remote_virtual_network_id
      allow_virtual_network_access      = true
      allow_forwarded_traffic           = false  # Disabled receiving forwarded traffic
      allow_gateway_transit             = false
      use_remote_gateways               = false
    }
  } : {}
}

# Create resource group for Application Gateway
module "rg_appgw" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  name     = local.appgw_resource_group
  location = var.location
}

/*
# Create public IP for Application Gateway using AVM module
module "appgw_pip" {
  source  = "Azure/avm-res-network-publicipaddress/azurerm"
  version = "0.1.0"

  name                = local.appgw_pip_name
  resource_group_name = module.rg_main.name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"]  # Making it zone-redundant to match the Application Gateway zones
}

module "application_gateway" {
  source             = "Azure/avm-res-network-applicationgateway/azurerm"
  version            = "0.3.0"

  # Resource group and location (use existing modules)
  resource_group_name = module.rg_appgw.name
  location            = var.location
  
  # Do not configure a public IP for the Application Gateway
  create_public_ip      = false

  # Provide Application gateway name 
  name = local.appgw_name

  # Only configure the private frontend IP
  frontend_ip_configuration_private = {
    name                          = "private-ip-config"
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.100.0.68" # IP from the AppGW subnet CIDR range
    subnet_id                     = module.vnet.subnets.appgw.resource_id
  }

  # Gateway IP configuration
  gateway_ip_configuration = {
    name      = "appGatewayIpConfig"
    subnet_id = module.vnet.subnets.appgw.resource_id
  }

  tags = {
    environment = "development"
  }

  # WAF: Using WAF_v2 for web application firewall capabilities
  sku = {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }
  
  # WAF configuration
  waf_configuration = {
    enabled                  = true
    firewall_mode            = "Prevention" # Can be Detection or Prevention
    rule_set_type            = "OWASP"
    rule_set_version         = "3.2"
    file_upload_limit_mb     = 100
    request_body_check       = true
    max_request_body_size_kb = 128
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

  # HTTP listeners - ensure it uses private IP configuration
  http_listeners = {
    default = {
      name                           = "default-listener"
      frontend_ip_configuration_name = "private-ip-config"  # Using private IP configuration only
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
    module.vnet
  ]
}

*/
# Create the reverse peering using official AVM peering module
module "vnet_peering_reverse" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm//modules/peering"
  version = "0.8.1"
  
  count                    = var.create_reverse_peering && var.remote_virtual_network_id != null && var.remote_resource_group_name != null && var.remote_vnet_full_name != null ? 1 : 0
  providers                = { azurerm = azurerm.remote_subscription }
  
  name                     = local.reverse_peering_name
  
  # Fixing the virtual_network input format
  virtual_network = {
    name                = var.remote_vnet_full_name
    resource_group_name = var.remote_resource_group_name
    resource_id         = var.remote_virtual_network_id # Adding the required resource_id field
  }
  
  # Fixing the remote_virtual_network input format
  remote_virtual_network = {
    id = module.vnet.resource.id
    resource_id = module.vnet.resource.id # Adding the required resource_id field
  }
  
  allow_virtual_network_access = true
  allow_forwarded_traffic      = false  # Disabled receiving forwarded traffic
  allow_gateway_transit        = false
  use_remote_gateways          = false

  # Ensure the forward peering is created first
  depends_on = [module.vnet]
}
