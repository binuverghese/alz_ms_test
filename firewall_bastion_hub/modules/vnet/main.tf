resource "azurerm_virtual_network" "vnet" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
}

resource "azurerm_subnet" "subnet" {
  for_each            = var.subnets
  name                = each.value.name
  resource_group_name = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes    = each.value.address_prefixes
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "subnets" {
  value = azurerm_subnet.subnet
}
