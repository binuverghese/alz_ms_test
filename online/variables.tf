variable "location" {
  description = "The Azure region to deploy resources in."
  type        = string
  default     = "Canada Central"
}

variable "main_rg_name" {
  description = "Name of the main resource group."
  type        = string
  default     = "rg-dev-003"
}

variable "appgw_rg_name" {
  description = "Name of the resource group for Application Gateway."  
  type        = string
  default     = "rg-appgw-dev"
 }

variable "hub_vnet_address_space" {
  description = "Address space for the Hub VNet."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "hub_subnets" {
  description = "Subnets in the Hub VNet."
  type = map(object({
    name             = string
    address_prefixes = list(string)
  }))
  default = {
    AzureFirewallSubnet = {
      name             = "AzureFirewallSubnet"
      address_prefixes = ["10.0.0.0/24"]
    }
    AppGatewaySubnet = {
      name             = "AppGatewaySubnet"
      address_prefixes = ["10.0.3.0/24"]
    }
  }
}

variable "appgw_name" {
  description = "Name of the Application Gateway."
  type        = string
  default     = "appgw-dev-003"
}

variable "appgw_sku" {
  description = "SKU config for App Gateway."
  type = object({
    name     = string
    tier     = string
    capacity = number
  })
  default = {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }
}

variable "appgw_backend_addresses" {
  description = "List of backend IP addresses for App Gateway."
  type = list(object({
    ip_address = string
  }))
  default = [
    { ip_address = "10.1.1.4" },
    { ip_address = "10.1.1.5" }
  ]
}

variable "appgw_public_ip_name" {
  description = "Name for the App Gateway public IP."
  type        = string
  default     = "appgw-pip"
}

variable "firewall_name" {
  default = "fw-dev"
}

variable "firewall_public_ip_name" {
  default = "fw-pip"
}

variable "firewall_sku_name" {
  default = "AZFW_VNet"
}

variable "firewall_sku_tier" {
  default = "Standard"
}

variable "firewall_ipconfig_name" {
  default = "fw-ipconfig"
}

variable "firewall_policy_id" {
  default = ""  
}

variable "bastion_name" {
  default = "bastion-dev"
}

variable "bastion_public_ip_name" {
  default = "bastion-pip"
}

variable "bastion_ip_config_name" {
  default = "bastion-ipconfig"
}

variable "tags" {
  default = {
    environment = "dev"
    owner       = "network-team"
  }
}

variable "firewall_policy_name" {
  type        = string
  description = "The name of the Azure Firewall Policy"
}
