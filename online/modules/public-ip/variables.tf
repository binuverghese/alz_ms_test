variable "name" {
  description = "The name of the public IP"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region for the public IP"
  type        = string
}
