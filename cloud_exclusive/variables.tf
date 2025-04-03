variable "location" {}
variable "resource_group_name" {}
variable "route_table_name" {}
variable "vnet_name" {}
variable "subnet_name" {}
variable "subnet_address_prefixes" {}
variable "address_space_vnet1" {}
variable "enable_vm_protection" {}
variable "dns_servers" {}
variable "storage_account_id" {}
variable "log_analytics_workspace_id" {}

variable "nsg_name" {
  description = "The name of the Network Security Group"
  type        = string
}

# Parameterizing Route Table `next_hop_type`
variable "next_hop_type" {
  description = "Type of next hop (e.g., VirtualAppliance, Internet, VnetLocal)"
  type        = string
  default     = "VirtualAppliance"
}

# Parameterizing Routes
variable "routes" {
  description = "List of routes"
  type = list(object({
    name           = string
    address_prefix = string
    next_hop_ip    = optional(string)
  }))
}

# Parameterizing Security Rules
variable "security_rules" {
  description = "List of security rules for the NSG"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_address_prefix      = string
    source_port_range          = string
    destination_address_prefix = string
    destination_port_range     = string
  }))
  default = [
    {
      name                       = "DenyInboundHTTPS"
      priority                   = 4096
      direction                  = "Inbound"
      access                     = "Deny"
      protocol                   = "*"
      source_address_prefix      = "*"
      source_port_range          = "*"
      destination_address_prefix = "*"
      destination_port_range     = "*"
    }
  ]
}
