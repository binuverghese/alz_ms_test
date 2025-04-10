resource "azurerm_subnet" "this" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.address_prefixes
}

resource "azurerm_subnet_network_security_group_association" "this" {
  count = var.create_nsg ? 1 : 0
  subnet_id                 = azurerm_subnet.this.id
  network_security_group_id = var.nsg_id
}

resource "azurerm_subnet_route_table_association" "this" {
  count = var.create_route_table ? 1 : 0
  subnet_id      = azurerm_subnet.this.id
  route_table_id = var.route_table_id
}
