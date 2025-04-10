variable "subscription_id" {}

variable "location" {}

variable "main_rg_name" {}
variable "appgw_rg_name" {}
variable "firewall_policy_rg_name" {}

variable "hub_vnet_name" {}
variable "hub_vnet_address_space" { type = list(string) }

variable "other_vnet_name" {}
variable "other_vnet_address_space" { type = list(string) }

variable "dns_resolver_name" {}

variable "firewall_name" {}
variable "firewall_policy_id" {}
variable "firewall_ipconfig_name" {}
variable "firewall_pip_name" {}

variable "appgw_name" {}
variable "appgw_public_ip_name" {}
