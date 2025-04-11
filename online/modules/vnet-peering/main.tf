resource "azurerm_virtual_network_peering" "example" {
  name                           = var.name
  resource_group_name            = var.resource_group_name
  virtual_network_name           = var.vnet_name
  remote_virtual_network_id      = var.remote_vnet_id
  allow_virtual_network_access   = true
  allow_forwarded_traffic       = true
  allow_gateway_transit         = false
  use_remote_gateways           = false
}
