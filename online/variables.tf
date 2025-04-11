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
variable "tags" {
  type        = map(string)
  description = "Tags to assign to the resources"
  default     = {
    environment = "dev"
    project     = "project_name"
  }
}
# modules/firewall-policy/variables.tf
variable "firewall_policy_name" {
  description = "The name of the firewall policy"
  type        = string
}
# modules/firewall-policy/variables.tf
variable "name" {}
variable "resource_group_name" {}
variable "policy_type" {}
variable "public_ip_id" {
  description = "The ID of the public IP to associate with the Application Gateway"
  type        = string
}

variable "public_ip_name" {
  description = "The name of the public IP address"
  type        = string
}

variable "inbound_name" {
  description = "Name of the inbound endpoint for DNS resolver"
  type        = string
}

variable "outbound_name" {
  description = "Name of the inbound endpoint for DNS resolver"
  type        = string
}

variable "dns_resolver_ip" {
  description = "The IP address for the DNS resolver"
  type        = string
}
