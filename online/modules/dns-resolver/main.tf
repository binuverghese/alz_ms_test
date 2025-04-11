esource "azurerm_private_dns_resolver" "dns_resolver" {
  name                = "example-dns-resolver"
  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_network_id  = var.virtual_network_id
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "inbound" {
  name                     = var.inbound_name
  location                 = var.location
  private_dns_resolver_id  = azurerm_private_dns_resolver.dns_resolver.id

  ip_configurations {
    subnet_id = var.inbound_subnet_id
  }
}

resource "azurerm_private_dns_resolver_outbound_endpoint" "outbound" {
  name                     = var.outbound_name
  location                 = var.location
  private_dns_resolver_id  = azurerm_private_dns_resolver.dns_resolver.id

  subnet_id = var.outbound_subnet_id
}




