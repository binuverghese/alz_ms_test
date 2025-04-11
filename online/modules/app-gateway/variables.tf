variable "name" {
  description = "The name of the application gateway"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region for the application gateway"
  type        = string
}

variable "sku_name" {
  description = "The SKU name of the application gateway"
  type        = string
}

variable "sku_tier" {
  description = "The SKU tier of the application gateway"
  type        = string
}

variable "sku_capacity" {
  description = "The capacity of the application gateway"
  type        = number
}

variable "frontend_ip_config_name" {
  description = "The name of the frontend IP configuration"
  type        = string
}

variable "public_ip_address_id" {
  description = "The public IP address ID for the frontend IP"
  type        = string
}

variable "frontend_port_name" {
  description = "The name of the frontend port"
  type        = string
}

variable "frontend_port" {
  description = "The frontend port number"
  type        = number
}

variable "subnet_id" {
  description = "The ID of the subnet for the application gateway"
  type        = string
}

variable "gateway_ip_config_name" {
  description = "The name of the gateway IP configuration"
  type        = string
}
variable "app_gateway_name" {
  description = "The name of the application gateway"
  type        = string
}
variable "public_ip_id" {
  description = "The ID of the public IP address for the Application Gateway"
  type        = string
}
