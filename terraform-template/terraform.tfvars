resource_group_name     = "rg-dev-008"
vnet_name               = "vnet-dev-canadacentral-008"
subnet_name             = "snet-dev-canadacentral-008"
subnet_address_prefixes = ["10.1.0.0/28"]

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
