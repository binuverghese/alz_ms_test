// Local variables for resource naming with concatenation
locals {
  // Resource specific names using concatenation
  vnet_name = "${var.naming_prefix}-vnet"
  vnet_rg_name = "${var.naming_prefix}-vnet-rg"
  subnet_name = "${var.naming_prefix}-snet"
  nsg_name = "${var.naming_prefix}-nsg"
  rt_name = "${var.naming_prefix}-rt"
  fw_name = "${var.naming_prefix}-fw"
  fwpp_name = "${var.naming_prefix}-fwpp"
  
  // Process the peering configuration to create formatted peering configurations
  vnet_peerings = var.enable_vnet_peering ? {
    for peer in var.peer_vnets : peer.name => {
      remote_virtual_network_id            = peer.remote_vnet_id
      allow_virtual_network_access         = peer.allow_virtual_network_access
      allow_forwarded_traffic              = peer.allow_forwarded_traffic
      allow_gateway_transit                = peer.allow_gateway_transit
      use_remote_gateways                  = peer.use_remote_gateways
    }
  } : {}
}

module "rg_main" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  name     = local.vnet_rg_name
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

# Virtual network with subnet and NSG association using AVM module
module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.1"

  name                = local.vnet_name
  location            = var.location
  resource_group_name = module.rg_main.name
  address_space       = var.address_space_vnet
    # Configure DNS servers properly using the required format
  dns_servers = {
    dns_servers = var.dns_servers
  }
  enable_vm_protection = var.enable_vm_protection
  
  encryption = {
    enabled     = var.encryption
    enforcement = var.encryption_enforcement
    type        = var.encryption_type
  }
  
  flow_timeout_in_minutes = var.flow_timeout_in_minutes
  
  # Define subnets using the AVM module with correct NSG association
  subnets = {
    "${local.subnet_name}" = {
      name                      = local.subnet_name
      address_prefixes          = var.subnet_address_prefixes
      network_security_group    = {
        id = module.nsg.resource.id
      }
    }
  }
  
  # VNet peering configuration
  # peerings = local.vnet_peerings

  depends_on = [module.nsg]
}
