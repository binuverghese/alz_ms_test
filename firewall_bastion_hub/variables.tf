variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region"
  type        = string
}

# Firewall Resources
variable "firewall_pip_name" {
  description = "The name for the firewall public IP"
  type        = string
}

variable "firewall_policy_name" {
  description = "The name for the firewall policy"
  type        = string
}

variable "firewall_name" {
  description = "The name of the Azure Firewall"
  type        = string
}

variable "firewall_ip" {
  description = "The IP address for the firewall"
  type        = string
}

# Bastion Resources
variable "bastion_ip_name" {
  description = "The name for the Bastion public IP"
  type        = string
}

variable "bastion_host_name" {
  description = "The name of the Bastion host"
  type        = string
}

# DNS Resolver Resources
variable "dns_resolver_name" {
  description = "The name of the DNS resolver"
  type        = string
}

# VNet Resources
variable "dns_vnet_name" {
  description = "The name of the DNS VNet"
  type        = string
}

variable "hub_vnet_name" {
  description = "The name of the Hub VNet"
  type        = string
}

variable "bastion_vnet_name" {
  description = "The name of the Bastion VNet"
  type        = string
}

# Address Space and Subnets for VNet
variable "hub_vnet_address_space" {
  description = "The address space for the Hub VNet"
  type        = list(string)
}

variable "dns_vnet_address_space" {
  description = "The address space for the DNS VNet"
  type        = list(string)
}

variable "bastion_vnet_address_space" {
  description = "The address space for the Bastion VNet"
  type        = list(string)
}

variable "hub_vnet_subnets" {
  description = "The subnets for the Hub VNet"
  type        = map(any)
}

variable "dns_vnet_subnets" {
  description = "The subnets for the DNS VNet"
  type        = map(any)
}

variable "bastion_vnet_subnets" {
  description = "The subnets for the Bastion VNet"
  type        = map(any)
}
