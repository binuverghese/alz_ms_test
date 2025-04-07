module "bastion" {
  source  = "Azure/avm-res-network-bastionhost/azurerm"
  version = "~> 0.3"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Standard"
  enable_telemetry    = false

  ip_configuration = {
    name                 = var.ip_config_name
    subnet_id            = var.subnet_id
    public_ip_address_id = var.public_ip_address_id
    create_public_ip     = false
  }

  copy_paste_enabled     = true
  file_copy_enabled      = false
  ip_connect_enabled     = true
  scale_units            = 2
  shareable_link_enabled = true
  tunneling_enabled      = true
  kerberos_enabled       = true

  tags = var.tags
}
