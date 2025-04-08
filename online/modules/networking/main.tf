# In modules/networking/main.tf (networking module)
variable "subnets" {
  description = "Map of subnet names and address prefixes"
  type        = map(object({
    address_prefixes = list(string)
  }))
}

variable "virtual_network_name" {
  description = "Name of the Virtual Network"
  type        = string
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "subnets" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = each.value.address_prefixes
}

output "subnet_ids" {
  value = { for name, subnet in azurerm_subnet.subnets : name => subnet.id }
}
output "appgw_subnet_id" {
  value = azurerm_subnet.app_gateway_subnet.id  # Adjust this based on your actual subnet resource
}
resource "azurerm_subnet" "app_gateway_subnet" {
  name                 = "AppGatewaySubnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = ["10.0.3.0/24"]
}
