output "peering_id" {
  description = "The ID of the VNet peering"
  value       = azurerm_virtual_network_peering.example.id
}
