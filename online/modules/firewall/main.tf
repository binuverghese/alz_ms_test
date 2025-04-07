module "firewall" {
  source  = "Azure/avm-res-network-azurefirewall/azurerm"
  version = "~> 0.3"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  firewall_sku_name   = var.firewall_sku_name
  firewall_sku_tier   = var.firewall_sku_tier
  firewall_policy_id  = var.firewall_policy_id

  firewall_ip_configuration = [
    {
      name                 = var.firewall_ipconfig_name
      subnet_id            = var.subnet_id
      public_ip_address_id = var.public_ip_address_id
    }
  ]
}
