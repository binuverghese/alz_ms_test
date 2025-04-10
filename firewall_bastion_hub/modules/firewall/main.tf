resource "azurerm_public_ip" "firewall_pip" {
  name                = var.firewall_ip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [1, 2, 3]
}

resource "azurerm_firewall_policy" "firewall_policy" {
  name                = var.firewall_policy_name
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "firewall" {
  source              = "./modules/firewall"
  name                = var.firewall_name
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name
  firewall_ip         = var.firewall_ip
  firewall_policy_id  = module.firewall_policy.firewall_policy_id
  firewall_sku_tier   = var.firewall_sku_tier  # Pass SKU tier
  firewall_sku_name   = var.firewall_sku_name  # Pass SKU name
}
