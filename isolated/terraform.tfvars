location                = "Canada Central"
resource_group_name     = "rg-dev-005"
route_table_name        = "rt-navigator5"
nsg_name                = "nsg-con-001"
vnet_name               = "vnet-dev-canadacentral-005"
address_space_vnet1     = ["172.0.0.0/24"]
dns_servers             = ["172.0.2.4"]
enable_vm_protection    = true
encryption              = false
subnet_name             = "snet-dev-canadacentral-001"
subnet_address_prefixes = ["172.0.0.0/24"]

# Next Hop Type for Route Table
next_hop_type = "VirtualAppliance"

# Routes
routes = [
  {
    name           = "Internet"
    address_prefix = "0.0.0.0/0"
    next_hop_ip    = "172.0.0.4"
  },
  {
    name           = "Hub"
    address_prefix = "172.0.0.0/24"
    next_hop_ip    = "172.0.0.4"
  },
  {
    name           = "Spokes"
    address_prefix = "172.1.0.0/16"
    next_hop_ip    = "172.0.0.4"
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

# Security Rules
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
