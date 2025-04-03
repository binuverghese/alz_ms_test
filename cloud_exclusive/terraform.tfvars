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
storage_account_id         = "/subscriptions/1e437fdf-bd78-431d-ba95-1498f0e84c10/resourceGroups/rg-dev-001/providers/Microsoft.Storage/storageAccounts/vnetlogssa"
log_analytics_workspace_id = "/subscriptions/1e437fdf-bd78-431d-ba95-1498f0e84c10/resourceGroups/rg-dev-001/providers/Microsoft.OperationalInsights/workspaces/vnetlaw"


# Next Hop Type for Route Table
next_hop_type = "VirtualAppliance"

# Routes
routes = [
  {
    name           = "Internet"
    address_prefix = "0.0.0.0/0"
    next_hop_ip    = "none"
  },
  {
    name           = "Hub"
    address_prefix = "10.0.0.0/24"
    next_hop_ip    = "none"
  },
  {
    name           = "Spokes"
    address_prefix = "10.1.0.0/16"
    next_hop_ip    = "none"
  },
  {
    name           = "On-Prem"
    address_prefix = "192.168.0.0/16"
    next_hop_ip    = "none"
  }
]

# Security Rules
security_rules = [
  {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "*"
  },
  {
    name                       = "AllowHTTP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_address_prefix = "*"
    destination_port_range     = "80"
  },
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
