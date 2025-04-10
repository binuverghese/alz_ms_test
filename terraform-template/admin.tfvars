location                = "Canada Central"
subscription_id         = "1e437fdf-bd78-431d-ba95-1498f0e84c10"
tenant_id               = "35db3582-96af-4081-a32c-7bbaa2cf3ca9"
client_id               = "ec375efa-27ef-4631-834f-05ddec12a417"
resource_group_name     = "rg-dev-003"
route_table_name        = "rt-navigator3"
nsg_name                = "nsg-con-003"
vnet_name               = "vnet-dev-canadacentral-003"
address_space_vnet     = ["10.1.0.0/24"]
dns_servers             = ["10.0.2.4"]
enable_vm_protection    = true
subnet_name             = "snet-dev-canadacentral-001"
subnet_address_prefixes = ["10.1.0.0/28"]

routes = [
  { name = "Internet", address_prefix = "0.0.0.0/0", next_hop_ip = "10.0.0.4" },
  { name = "Hub",      address_prefix = "10.0.0.0/24", next_hop_ip = "10.0.0.4" },
  { name = "Spokes",   address_prefix = "10.1.0.0/16", next_hop_ip = "10.0.0.4" },
  { name = "On-Prem",  address_prefix = "192.168.0.0/16", next_hop_ip = "10.0.0.4" },
  { name = "KMS1",     address_prefix = "20.118.99.224/32", next_hop_ip = null },
  { name = "KMS2",     address_prefix = "40.83.235.53/32",  next_hop_ip = null }
]

