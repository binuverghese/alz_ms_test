variable "subscription_id" { type = string }
variable "tenant_id" { type = string }
variable "client_id" { type = string }

# Simplified naming convention variables
variable "naming_prefix" {
  type = string
  description = "Resource naming prefix following the format: BU-Region-Archetype-WL-Env-WLDesc (e.g., ns-cc-corp-shs-prod-core_hub)"
}

variable "location" { type = string }

# Network configuration
variable "address_space_vnet" { 
  type = list(string)
  description = "Address space for the virtual network" 
}

variable "subnet_address_prefixes" { 
  type = list(string)
  description = "Address prefixes for the subnet"
}

variable "dns_servers" { 
  type = list(string)
  description = "List of DNS servers for the virtual network"
}

# Network feature flags
variable "enable_vm_protection" { type = bool }
variable "encryption" { 
  description = "Enable encryption"
  type = bool 
}

variable "flow_timeout_in_minutes" {
  description = "Flow timeout in minutes"
  type = number
  default = 4
}

variable "encryption_enforcement" {
  type = string
  default = "DropUnencrypted"
}

variable "encryption_type" {
  type = string
  default = "enabled"
}

# NSG configuration
variable "security_rules" {
  description = "List of security rules for the NSG"
  type = list(object({
    name = string
    priority = number
    direction = string
    access = string
    protocol = string
    source_port_range = string
    destination_port_range = string
    source_address_prefix = string
    destination_address_prefix = string
  }))
  default = []
}

# Feature flags
variable "create_nsg" {
  type = bool
  default = true
}

variable "create_route_table" {
  type = bool
  default = true
}

# VNet Peering configuration
variable "enable_vnet_peering" {
  description = "Enable or disable VNet peering"
  type        = bool
  default     = false
}

variable "peer_vnets" {
  description = "List of VNets to peer with"
  type = list(object({
    name                      = string
    remote_vnet_name          = string
    remote_vnet_id            = string
    remote_resource_group_name = string
    allow_virtual_network_access = bool
    allow_forwarded_traffic     = bool
    allow_gateway_transit       = bool
    use_remote_gateways         = bool
  }))
  default = []
}
