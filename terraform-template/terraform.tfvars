resource_group_name     = "rg-dev-010"
vnet_name               = "vnet-dev-canadacentral-010"
subnet_name             = "snet-dev-canadacentral-010"
subnet_address_prefixes = ["10.1.0.0/28"]
enable_vm_protection    = true
encryption              = false
route_table_name        = "rt-navigator10"
nsg_name                = "nsg-con-0010"
address_space_vnet1     = ["10.1.0.0/24"]

create_nsg        = true
create_route_table = true


subscription_id = "1e437fdf-bd78-431d-ba95-1498f0e84c10"
tenant_id       = "35db3582-96af-4081-a32c-7bbaa2cf3ca9"
client_id       = "ec375efa-27ef-4631-834f-05ddec12a417"
location        = "canadacentral" 

dns_servers             = ["10.0.2.4"]

security_rules = [
  {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  }
]

# Next Hop Type for Route Table
next_hop_type = "VirtualAppliance"

# Routes
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
  },
	
    {
    name           = "KMS1"
    address_prefix = "20.118.99.224/32"
    next_hop_ip    = null
  },
{
    name           = "KMS2"
    address_prefix = "40.83.235.53/32"
    next_hop_ip    = null
  }
]
