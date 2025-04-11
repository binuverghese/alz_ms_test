variable "name" {
  description = "The name of the VNet peering"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
}

variable "remote_vnet_id" {
  description = "The ID of the remote virtual network"
  type        = string
}
