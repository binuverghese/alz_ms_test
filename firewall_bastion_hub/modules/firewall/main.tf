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
  source              = "Azure/avm-res-network-azurefirewall/azurerm"
  name                = var.firewall_name
  location            = var.location
  resource_group_name = var.resource_group_name
  firewall_policy_id  = azurerm_firewall_policy.firewall_policy.id
}
