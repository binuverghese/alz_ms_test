resource "azurerm_bastion_host" "bastion" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_name            = var.dns_name

  ip_configuration {
    name                 = "ipconfig1"
    subnet_id            = var.subnet_id
    public_ip_address_id = var.public_ip_id
  }
}
