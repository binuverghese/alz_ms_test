variable "virtual_network_name" {
  description = "The name of the virtual network."
  type        = string
}

variable "location" {
  description = "The location where the virtual network will be deployed."
  type        = string
}

variable "resource_group_name" {
  description = "The resource group name where the virtual network will be deployed."
  type        = string
}

variable "address_space" {
  description = "The address space for the virtual network."
  type        = list(string)
}

variable "subnets" {
  description = "A map of subnets to create within the virtual network."
  type = map(object({
    name                      = string
    address_prefixes          = list(string)
    network_security_group_id = string
    route_table_id            = string
  }))
}


variable "enable_vm_protection" {
  type        = bool
  description = "Whether to enable VM protection"
  default     = false
}

variable "encryption" {
  type        = any
  description = "Encryption configuration for the VNet"
  default     = null
}

variable "flow_timeout_in_minutes" {
  type        = number
  description = "The timeout in minutes for flow logs"
  default     = null
}
variable "dns_servers" {
  description = "List of DNS servers."
  type        = list(string)
  default     = []
}

