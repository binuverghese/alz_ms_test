module "nsg" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "~> 0.1"

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  security_rules      = var.security_rules
}
