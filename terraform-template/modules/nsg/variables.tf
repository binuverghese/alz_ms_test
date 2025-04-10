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
  description = "Security rules for the Network Security Group"
  type        = list(object({
    name                       = string
    priority                  = number
    direction                 = string
    access                    = string
    protocol                  = string
    source_port_range         = string
    destination_port_range    = string
    source_address_prefix     = string
    destination_address_prefix = string
  }))
  default = []
}

