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
