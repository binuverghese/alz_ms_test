module "route_table" {
  source  = "Azure/avm-res-network-routetable/azurerm"
  version = "~> 0.1"

  name                = var.route_table_name
  location            = var.location
  resource_group_name = var.resource_group_name
  routes              = var.routes
}
