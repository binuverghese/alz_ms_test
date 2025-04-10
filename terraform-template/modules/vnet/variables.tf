variable "name" {
  type        = string
  description = "Name of the virtual network"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "location" {
  type        = string
  description = "Location"
}

variable "address_space" {
  type        = list(string)
  description = "The address space that is used the virtual network"
}
