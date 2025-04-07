variable "application_gateway_name" {
  description = "Name of the Application Gateway"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "appgw_subnet_id" {
  description = "Subnet ID for the Application Gateway"
  type        = string
}

variable "appgw_public_ip_id" {
  description = "Public IP ID for the Application Gateway"
  type        = string
}

variable "sku_name" {
  description = "SKU name for App Gateway"
  type        = string
  default     = "Standard_v2"
}

variable "sku_tier" {
  description = "SKU tier for App Gateway"
  type        = string
  default     = "Standard_v2"
}

variable "capacity" {
  description = "Instance count (capacity)"
  type        = number
  default     = 2
}

variable "firewall_pip_name" {
  description = "Name of the firewall public IP"
  type        = string
}
