resource "azurerm_firewall" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  sku_name = var.firewall_sku_name
  sku_tier = var.firewall_sku_tier

  firewall_policy_id = var.firewall_policy_id

  dynamic "ip_configuration" {
    for_each = var.firewall_ip_configuration
    content {
      name                 = ip_configuration.value.name
      public_ip_address_id = ip_configuration.value.public_ip_address_id
      subnet_id            = ip_configuration.value.subnet_id
    }
  }
}

output "firewall_private_ip" {
  value = azurerm_firewall.this.ip_configuration[0].private_ip_address
}

output "firewall_id" {
  value = azurerm_firewall.this.id
}
