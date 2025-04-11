variable "name" {
  description = "The name of the firewall policy"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region in which to create the firewall policy"
  type        = string
}

variable "policy_type" {
  description = "The type of firewall policy (Standard or Premium)"
  type        = string
}
