resource "azurerm_bastion_host" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = "configuration"
    public_ip_address_id = var.public_ip_id
    subnet_id            = var.subnet_id
  }

  dns_name             = var.dns_name
  scale_units          = var.scale_units
  ip_connect_enabled   = var.ip_connect_enabled
  tunneling_enabled    = var.tunneling_enabled
  kerberos_enabled     = var.kerberos_enabled

  tags = var.tags
}
