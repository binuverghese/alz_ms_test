variable "name" {
  type        = string
  description = "Name of the virtual network"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "address_space" {
  type        = list(string)
  description = "The address space for the virtual network"
}

variable "dns_servers" {
  type        = list(string)
  description = "List of DNS servers"
}

variable "enable_vm_protection" {
  type        = bool
  description = "Enable VM protection"
}
