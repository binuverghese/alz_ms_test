variable "name" {
  description = "The name of the virtual network"
  type        = string
}

variable "location" {
  description = "The Azure region in which to create the VNet"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group to associate with the VNet"
  type        = string
}

variable "address_space" {
  description = "The address space for the VNet"
  type        = list(string)
}

variable "subnets" {
  description = "A list of subnets to create in the VNet"
  type = list(object({
    name           = string
    address_prefix = string
  }))
}
variable "public_ip_id" {
  description = "Optional public IP ID"
  type        = string
  default     = null
}
