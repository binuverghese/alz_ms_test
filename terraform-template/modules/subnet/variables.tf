variable "vnet_id" {
  type        = string
  description = "The ID of the virtual network"
}

variable "subnet_name" {
  type        = string
  description = "Subnet name"
}

variable "address_prefixes" {
  type        = list(string)
  description = "List of address prefixes for the subnet"
}

variable "route_table_id" {
  type        = string
  description = "ID of the route table to associate (optional)"
  default     = null
}

variable "nsg_id" {
  type        = string
  description = "ID of the NSG to associate (optional)"
  default     = null
}
variable "resource_group_name" {
  type        = string
  description = "The resource group name"
}

variable "vnet_name" {
  type        = string
  description = "The virtual network name"
}
