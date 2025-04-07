location         = "Canada Central"

main_rg_name     = "rg-dev-002"
appgw_rg_name    = "rg-appgw-dev"

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
