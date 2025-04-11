variable "inbound_name" {
  description = "The name for the inbound DNS resolver endpoint"
  type        = string
}

variable "outbound_name" {
  description = "The name for the outbound DNS resolver endpoint"
  type        = string
}

variable "dns_resolver_ip" {
  description = "The IP address of the DNS resolver"
  type        = string
}


variable "location" {
  description = "Location of the DNS Resolver"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name for the DNS Resolver"
  type        = string
}

variable "virtual_network_id" {
  description = "ID of the virtual network"
  type        = string
}

variable "inbound_subnet_id" {
  description = "Subnet ID for inbound endpoint"
  type        = string
}

variable "outbound_subnet_id" {
  description = "Subnet ID for outbound endpoint"
  type        = string
}







