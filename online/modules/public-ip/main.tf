resource "azurerm_public_ip" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  #zones               = [1, 2, 3]
}

output "id" {
  value = azurerm_public_ip.this.id
}
