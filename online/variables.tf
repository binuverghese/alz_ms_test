variable "location" {
  description = "The Azure region to deploy resources in."
  type        = string
}

variable "main_rg_name" {
  description = "Name of the main resource group."
  type        = string
}

variable "appgw_rg_name" {
  description = "Name of the resource group for Application Gateway."
  type        = string
}

variable "hub_vnet_address_space" {
  description = "Address space for the Hub VNet."
  type        = list(string)
}

variable "hub_subnets" {
  description = "Subnets in the Hub VNet."
  type = map(object({
    name             = string
    address_prefixes = list(string)
  }))
}

variable "appgw_name" {
  description = "Name of the Application Gateway."
  type        = string
}

variable "appgw_sku" {
  description = "SKU config for App Gateway."
  type = object({
    name     = string
    tier     = string
    capacity = number
  })
}

variable "appgw_backend_addresses" {
  description = "List of backend IP addresses for App Gateway."
  type = list(object({
    ip_address = string
  }))
}

variable "appgw_zones" {
  description = "Availability Zones for App Gateway Public IP."
  type        = list(number)
}

variable "appgw_public_ip_name" {
  description = "Name for the App Gateway public IP."
  type        = string
}

variable "public_ip_address_id" {
  type = string
}

variable "appgw_subnet_id" {
  type = string
}
