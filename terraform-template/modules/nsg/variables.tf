variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "nsg_name" {
  type        = string
  description = "Network Security Group name"
}

variable "security_rules" {
  description = "List of security rules"
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
    description = "List of security rules"
}

