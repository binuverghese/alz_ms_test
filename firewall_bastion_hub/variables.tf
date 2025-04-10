# variables.tf

variable "location" {
  type    = string
  default = "Canada Central"
}

variable "resource_group_name" {
  type    = string
  default = "rg-dev-001"
}

variable "hub_vnet_name" {
  type    = string
  default = "hub-vnet"
}

variable "hub_vnet_address_space" {
  type    = list(string)
  default = ["10.0.0.0/16"]
}

variable "hub_vnet_subnets" {
  type = map(any)
  default = {
    AzureFirewallSubnet = {
      name             = "AzureFirewallSubnet"
      address_prefixes = ["10.0.0.0/24"]
    }
  }
}

# Define other variables here...
