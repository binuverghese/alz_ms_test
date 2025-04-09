# Provider Configuration
variable "subscription_id" {
  description = "The Subscription ID for Azure"
  type        = string
}

# Resource Group
variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-dev-003"
}

variable "location" {
  description = "The Azure region where the resources will be created"
  type        = string
  default     = "Canada Central"
}

# Firewall Resources
variable "firewall_pip_name" {
  description = "The name of the firewall public IP"
  type        = string
  default     = "firewall-public-ip"
}

variable "firewall_policy_name" {
  description = "The name of the firewall policy"
  type        = string
  default     = "firewall-policy"
}

variable "firewall_name" {
  description = "The name of the firewall"
  type        = string
  default     = "firewall"
}

variable "firewall_sku_tier" {
  description = "The SKU tier for the firewall"
  type        = string
  default     = "Standard"
}

variable "firewall_sku_name" {
  description = "The SKU name for the firewall"
  type        = string
  default     = "AZFW_VNet"
}

variable "firewall_ipconfig_name" {
  description = "The name of the firewall IP configuration"
  type        = string
  default     = "firewall-ipconfig"
}

# Bastion Resources
variable "bastion_ip_name" {
  description = "The name of the bastion public IP"
  type        = string
  default     = "bastion-public-ip"
}

variable "bastion_host_name" {
  description = "The name of the bastion host"
  type        = string
  default     = "bastion-host"
}

# DNS VNet Resources
variable "dns_vnet_name" {
  description = "The name of the DNS VNet"
  type        = string
  default     = "dns-vnet"
}

# Hub VNet Resources
variable "hub_vnet_name" {
  description = "The name of the Hub VNet"
  type        = string
  default     = "hub-vnet"
}

# Bastion VNet Resources
variable "bastion_vnet_name" {
  description = "The name of the Bastion VNet"
  type        = string
  default     = "bastion-vnet"
}
