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
  dns_zone_rg_name = "${local.name_prefix}-dns-rg"
  
  # Derived names
  peering_name = "peer-${local.vnet_name}-to-remote-vnet"
  
#   # Common private DNS zones for Azure services
#   private_dns_zones = {
#     "blob"      = "privatelink.blob.core.windows.net"
#     "file"      = "privatelink.file.core.windows.net"
#     "queue"     = "privatelink.queue.core.windows.net"
#     "table"     = "privatelink.table.core.windows.net"
#     "sql"       = "privatelink.database.windows.net"
#     "keyvault"  = "privatelink.vaultcore.azure.net"
#     "websites"  = "privatelink.azurewebsites.net"
#     "acr"       = "privatelink.azurecr.io"
#     "cosmos-sql"= "privatelink.documents.azure.com"
#   }
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

# Resource Group for Private DNS Zones
module "rg_dns" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  name     = local.dns_zone_rg_name
  location = var.location
}

# Route Table
module "route_table" {
  source  = "Azure/avm-res-network-routetable/azurerm"
  version = "0.4.1"

  name                = local.rt_name
  location            = var.location
  resource_group_name = module.rg_main.name
  
  routes = {
    for idx, route in var.routes : route.name => {
      name                   = route.name
      address_prefix         = route.address_prefix
      next_hop_type          = route.next_hop_type
      next_hop_in_ip_address = route.next_hop_ip
    }
  }
  
  # Associate route table with subnet
  subnet_resource_ids = {
    subnet1 = "${module.vnet.resource.id}/subnets/${local.subnet_name}"
  }

  depends_on = [module.rg_main, module.vnet]
}

# # Private DNS Zones
# module "private_dns_zones" {
#   source  = "Azure/avm-res-network-privatednszone/azurerm"
#   version = "0.1.1"
  
#   for_each = local.private_dns_zones

#   domain_name         = each.value
#   resource_group_name = module.rg_dns.name
  
#   virtual_network_links = {
#     "link-to-${local.vnet_name}" = {
#       virtual_network_resource_id    = module.vnet.resource.id
#       registration_enabled           = false
#       virtual_network_link_name      = "link-to-${local.vnet_name}"
#     }
#   }

#   depends_on = [module.rg_dns, module.vnet]
# }
