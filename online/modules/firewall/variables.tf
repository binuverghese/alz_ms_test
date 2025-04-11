variable "name" {
  description = "The name of the firewall"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region for the firewall"
  type        = string
}

variable "firewall_sku_name" {
  description = "The SKU name of the firewall"
  type        = string
}

variable "firewall_sku_tier" {
  description = "The SKU tier of the firewall"
  type        = string
}

variable "firewall_policy_id" {
  description = "The ID of the firewall policy"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet for the firewall"
  type        = string
}

variable "public_ip_id" {
  description = "The ID of the public IP address for the firewall"
  type        = string
}

variable "firewall_name" {
  description = "The name of the firewall"
  type        = string
}
