resource "azurerm_route_table" "this" {
  name                = var.route_table_name
  location            = var.location
  resource_group_name = var.resource_group_name

  dynamic "route" {
    for_each = var.routes
    content {
      name                   = route.value.name
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_ip != null ? "VirtualAppliance" : "Internet"
      next_hop_in_ip_address = route.value.next_hop_ip
    }
  }
}

#resource "azurerm_subnet_route_table_association" "assoc" {
#  subnet_id      = var.subnet_id
 # route_table_id = azurerm_route_table.this.id
#}
