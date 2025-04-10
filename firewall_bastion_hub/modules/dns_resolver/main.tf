resource "azurerm_dns_resolver" "dns_resolver" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_network_id  = var.virtual_network_id
}

resource "azurerm_dns_resolver_inbound_endpoint" "inbound" {
  for_each = var.inbound_endpoints
  name                = each.value.name
  subnet_id           = each.value.subnet_id
  dns_resolver_id     = azurerm_dns_resolver.dns_resolver.id
}

resource "azurerm_dns_resolver_outbound_endpoint" "outbound" {
  for_each = var.outbound_endpoints
  name                = each.value.name
  subnet_id           = each.value.subnet_id
  dns_resolver_id     = azurerm_dns_resolver.dns_resolver.id
}

output "dns_resolver_id" {
  value = azurerm_dns_resolver.dns_resolver.id
}
