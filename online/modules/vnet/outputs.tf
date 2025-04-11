output "name" {
  description = "The name of the virtual network"
  value       = azurerm_virtual_network.example.name
}

output "resource_group_name" {
  description = "The name of the resource group associated with the virtual network"
  value       = azurerm_virtual_network.example.resource_group_name
}

output "subnet_ids" {
  description = "A map of subnet names to subnet IDs"
  value = { for subnet in azurerm_subnet.example : subnet.name => subnet.id }
}

output "id" {
  value = azurerm_virtual_network.example.id
}
