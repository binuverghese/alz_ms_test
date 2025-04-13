resource_group_name     = "rg-dev-011"
vnet_name               = "vnet-dev-canadacentral-011"
subnet_name             = "snet-dev-canadacentral-011"
subnet_address_prefixes = ["10.1.0.0/28"]
enable_vm_protection    = true
encryption              = false
nsg_name                 = "nsg-011"
route_table_name         = "rt-navigator11"

vnet_address_space = ["10.0.0.0/16"]
address_space_vnet1     = ["10.1.0.0/24"]

address_space = ["10.0.0.0/24"]
location              = "canadacentral"
virtual_network_name  = "testvnet11"


security_rules = {
"DenyAllInbound" = {
  name                       = "DenyAllInbound"
  priority                   = 100
  direction                  = "Inbound"
  access                     = "Deny"
  protocol                   = "*"
  source_port_range          = "*"
  destination_port_range     = "*"
  source_address_prefix      = "*"
  destination_address_prefix = "*"
}
}



routes = {
  "Internet" = {
    name                = "Internet"
    address_prefix      = "0.0.0.0/0"
    next_hop_type       = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.0.4"
  }
  "Hub" = {
    name                = "Hub"
    address_prefix      = "10.0.0.0/24"
    next_hop_type       = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.0.4"
  }
  "Spokes" = {
    name                = "Spokes"
    address_prefix      = "10.1.0.0/16"
    next_hop_type       = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.0.4"
  }
  "OnPrem" = {
    name                = "On-Prem"
    address_prefix      = "192.168.0.0/16"
    next_hop_type       = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.0.4"
  }
  "KMS1" = {
    name                = "KMS1"
    address_prefix      = "20.118.99.224/32"
    next_hop_type       = "Internet"
    next_hop_in_ip_address = null
  }
  "KMS2" = {
    name                = "KMS2"
    address_prefix      = "40.83.235.53/32"
    next_hop_type       = "Internet"
    next_hop_in_ip_address = null
  }
}
subnets = {
  "subnet11" = {
    name                      = "subnet11"
    address_prefixes          = ["10.0.1.0/24"]
    network_security_group_id = "your-nsg-id11"
    route_table_id            = "your-route-table-id11"
  }
}
