location         = "Canada Central"

main_rg_name     = "rg-dev-003"
appgw_rg_name    = "rg-appgw-dev"

bastion_pip_name = "bastionpiptest"
firewall_pip_name = "firewallpiptest"
firewall_policy_name = "firewalltesting"

name               = "my-resource-group"
resource_group_name = "my-resource-group"

hub_vnet_address_space = ["10.0.0.0/16"]

hub_subnets = {
  AzureFirewallSubnet = {
    name             = "AzureFirewallSubnet"
    address_prefixes = ["10.0.0.0/24"]
  }
  AppGatewaySubnet = {
    name             = "AppGatewaySubnet"
    address_prefixes = ["10.0.3.0/24"]
  }
}

appgw_name = "appgw-dev-001"

appgw_sku = {
  name     = "WAF_v2"
  tier     = "WAF_v2"
  capacity = 2
}

appgw_backend_addresses = [
  { ip_address = "10.1.1.4" },
  { ip_address = "10.1.1.5" }
]

appgw_zones = [1, 2, 3]

appgw_public_ip_name = "appgw-pip"

# Firewall
firewall_name           = "fw-dev"
firewall_public_ip_name = "fw-pip"
firewall_sku_name       = "AZFW_VNet"
firewall_sku_tier       = "Standard"
firewall_ipconfig_name  = "fw-ipconfig"
firewall_policy_id      = ""  # Fill this in with actual Firewall Policy ID

# Bastion
bastion_name             = "bastion-dev"
bastion_public_ip_name   = "bastion-pip"
bastion_ip_config_name   = "bastion-ipconfig"

tags = {
  environment = "dev"
  owner       = "network-team"
}
