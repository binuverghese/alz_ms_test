
module "resource_group_main" {
  source  = "./modules/resource-group"
  name    = var.main_rg_name
  location = var.location
}

module "resource_group_appgw" {
  source  = "./modules/resource-group"
  name    = var.appgw_rg_name
  location = var.location
}

module "resource_group_firewall_policy" {
  source  = "./modules/resource-group"
  name    = var.firewall_policy_rg_name
  location = var.location
}

module "vnet_hub" {
  source              = "./modules/vnet"
  name                = var.hub_vnet_name
  address_space       = var.hub_vnet_address_space
  location            = var.location
  resource_group_name = module.resource_group_main.name

  subnets = {
    AzureFirewallSubnet = {
      name             = "AzureFirewallSubnet"
      address_prefixes = ["10.0.0.0/24"]
    }
    AppGatewaySubnet = {
      name             = "AppGatewaySubnet"
      address_prefixes = ["10.0.3.0/24"]
    }
    DNSResolverInbound = {
      name             = "dns-inbound"
      address_prefixes = ["10.0.4.0/28"]
    }
    DNSResolverOutbound = {
      name             = "dns-outbound"
      address_prefixes = ["10.0.5.0/28"]
    }
  }
}

module "vnet_other" {
  source              = "./modules/vnet"
  name                = var.other_vnet_name
  address_space       = var.other_vnet_address_space
  location            = var.location
  resource_group_name = module.resource_group_main.name
}

module "vnet_peering" {
  source = "./modules/vnet-peering"

  vnet1_name              = module.vnet_hub.name
  vnet1_rg                = module.resource_group_main.name
  vnet1_remote_vnet_id    = module.vnet_other.id

  vnet2_name              = module.vnet_other.name
  vnet2_rg                = module.resource_group_main.name
  vnet2_remote_vnet_id    = module.vnet_hub.id
}

module "dns_resolver" {
  source              = "./modules/dns-resolver"
  name                = var.dns_resolver_name
  location            = var.location
  resource_group_name = module.resource_group_main.name
  vnet_id             = module.vnet_hub.id

  inbound_subnet_id   = module.vnet_hub.subnet_ids["DNSResolverInbound"]
  outbound_subnet_id  = module.vnet_hub.subnet_ids["DNSResolverOutbound"]
}

module "firewall" {
  source                  = "./modules/firewall"
  name                    = var.firewall_name
  resource_group_name     = module.resource_group_main.name
  location                = var.location
  firewall_policy_id      = var.firewall_policy_id
  firewall_ipconfig_name  = var.firewall_ipconfig_name
  subnet_id               = module.vnet_hub.subnet_ids["AzureFirewallSubnet"]
  public_ip_address_id    = module.firewall_pip.id
}

module "firewall_pip" {
  source              = "./modules/public-ip"
  name                = var.firewall_pip_name
  resource_group_name = module.resource_group_main.name
  location            = var.location
}

module "app_gateway" {
  source                          = "./modules/app-gateway"
  name                            = var.appgw_name
  resource_group_name             = module.resource_group_appgw.name
  location                        = var.location
  public_ip_resource_id          = module.appgw_pip.id
  subnet_id                       = module.vnet_hub.subnet_ids["AppGatewaySubnet"]
}

module "appgw_pip" {
  source              = "./modules/public-ip"
  name                = var.appgw_public_ip_name
  resource_group_name = module.resource_group_appgw.name
  location            = var.location
}
