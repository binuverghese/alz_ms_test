# Provider Configuration
subscription_id = "1e437fdf-bd78-431d-ba95-1498f0e84c10"

# Resource Group
resource_group_name = "rg-dev-007"
location            = "Canada Central"

# Firewall Resources
firewall_pip_name      = "firewall-public-ip"
firewall_policy_name   = "firewall-policy"
firewall_name          = "firewall"
firewall_sku_tier      = "Standard"
firewall_sku_name      = "AZFW_VNet"
firewall_ipconfig_name = "firewall-ipconfig"

# bastion_vnet module variables
bastion_vnet_name          = "bastion-vnet"
bastion_vnet_address_space = ["10.0.0.0/16"]
bastion_vnet_subnets = {
  subnet1 = {
    name           = "subnet1"
    address_prefix = "10.0.0.0/24"
  },
}

# bastion module variables
bastion_name              = "bastion-host"
location                 = "Canada Central"
bastion_ip_name          = "bastion-public-ip"

# DNS VNet Resources
dns_vnet_name = "dns-vnet"

# Hub VNet Resources
hub_vnet_name = "hub-vnet"


