module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.1"

  name                = var.virtual_network_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space

  dns_servers = {
    dns_servers = var.dns_servers
  }
  enable_vm_protection = var.enable_vm_protection
  encryption          = var.encryption
  flow_timeout_in_minutes = var.flow_timeout_in_minutes
  subnets             = var.subnets
}
