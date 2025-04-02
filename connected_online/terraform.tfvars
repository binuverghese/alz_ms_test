location                = "Canada Central"
resource_group_name     = "rg-dev-001"
route_table_name        = "rt-navigator"
nsg_name                = "nsg-con-001"
vnet_name               = "vnet-dev-canadacentral-001"
address_space_vnet1     = ["10.0.0.0/24"]
dns_servers             = ["10.0.0.4"]
enable_vm_protection    = true
encryption              = false
subnet_name             = "snet-dev-canadacentral-001"
subnet_address_prefixes = ["10.0.0.0/28"]

routes = [
  {
    name           = "Internet"
    address_prefix = "0.0.0.0/0"
    next_hop_ip    = "10.0.0.4"
  },
  {
    name           = "Hub"
    address_prefix = "10.0.0.0/24"
    next_hop_ip    = "10.0.0.4"
  },
  {
    name           = "Spokes"
    address_prefix = "10.1.0.0/16"
    next_hop_ip    = "10.0.0.4"
  },
  {
    name           = "On-Prem"
    address_prefix = "192.168.0.0/16"
    next_hop_ip    = "10.0.0.4"
  }
]
