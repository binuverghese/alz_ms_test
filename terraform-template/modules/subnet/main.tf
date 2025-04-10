resource "azurerm_subnet" "this" {
  name                 = var.subnet_name
  resource_group_name  = split("/", var.vnet_id)[4]
  virtual_network_name = split("/", var.vnet_id)[8]
  address_prefixes     = var.address_prefixes
}

