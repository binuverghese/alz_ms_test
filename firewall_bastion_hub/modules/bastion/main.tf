resource "azurerm_bastion_host" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_name            = var.dns_name
  scale_units         = var.scale_units

  ip_configuration {
    name                 = "ipconfig"
    subnet_id            = var.subnet_id
    public_ip_address_id = var.public_ip_id
  }

  ip_connect_enabled    = var.ip_connect_enabled
  tunneling_enabled     = var.tunneling_enabled
  kerberos_enabled      = var.kerberos_enabled
  copy_paste_enabled    = var.copy_paste_enabled
  file_copy_enabled     = var.file_copy_enabled

  tags = var.tags
}
