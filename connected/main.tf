locals {
  # Base naming pattern: BU-Region-Archetype-WL-Env-WLDesc
  #name_prefix = "${var.business_unit}-${var.region_short}-${var.archetype}-${var.workload}-${var.environment}-${var.workload_description}"
  name_prefix = "${var.business_unit}-${var.region_short}-${var.archetype}-${var.workload}-${var.environment}"
  # Resource-specific names
  vnet_name = "${local.name_prefix}-vnet"
  subnet_name = "${local.name_prefix}-snet"
  nsg_name = "${local.name_prefix}-nsg"
  rg_name = "${local.name_prefix}-vnet-rg"
  rt_name = "${local.name_prefix}-rt"
  
  # Derived names
  peering_name = "peer-${local.vnet_name}-to-remote-vnet"
}

module "rg_main" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  name     = local.rg_name
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

# Virtual network with integrated subnet and NSG association
module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.1"

  name                = local.vnet_name
  location            = var.location
  resource_group_name = module.rg_main.name
  address_space       = var.address_space_vnet1
  
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
  
  # Define subnets directly in the VNet module with NSG association
  subnets = {
    "${local.subnet_name}" = {
      name                                     = local.subnet_name
      address_prefixes                         = var.subnet_address_prefixes
      network_security_group = {
        id = module.nsg.resource.id
      }
      private_endpoint_network_policies_enabled = true
    }
  }

  # Add peering configuration only if remote_virtual_network_id is provided
  # peerings = var.remote_virtual_network_id != null ? {
  #   peer-to-remote-vnet = {
  #     name                              = local.peering_name
  #     remote_virtual_network_resource_id = var.remote_virtual_network_id
  #     allow_virtual_network_access      = true
  #     allow_forwarded_traffic           = true
  #     allow_gateway_transit             = false
  #     use_remote_gateways               = false
  #   }
  # } : {}
  
  depends_on = [module.rg_main, module.nsg]
}
