variable "name" {
  description = "The name of the firewall"
  type        = string
}

variable "location" {
  description = "The location of the firewall"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "firewall_sku_tier" {
  description = "The SKU tier of the firewall"
  type        = string
}

variable "firewall_sku_name" {
  description = "The SKU name of the firewall"
  type        = string
}

variable "firewall_policy_id" {
  description = "The ID of the firewall policy"
  type        = string
}

variable "firewall_ip_configuration" {
  description = "The list of IP configurations for the firewall"
  type = list(object({
    name                 = string
    public_ip_address_id = string
    subnet_id            = string
  }))
}
