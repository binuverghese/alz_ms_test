location                = "Canada Central"
resource_group_name     = "rg-dev-001"
route_table_name        = "rt-navigator"
nsg_name                = "nsg-con-001"
vnet_name               = "vnet-dev-canadacentral-001"
address_space_vnet1     = ["10.1.1.0/24"]
dns_servers             = ["10.0.2.4"]
enable_vm_protection    = true
encryption              = false
subnet_name             = "snet-dev-canadacentral-001"
subnet_address_prefixes = ["10.1.1.0/28"]
storage_account_id         = "/subscriptions/1e437fdf-bd78-431d-ba95-1498f0e84c10/resourceGroups/rg-dev-001/providers/Microsoft.Storage/storageAccounts/vnetlogssa"
log_analytics_workspace_id = "/subscriptions/1e437fdf-bd78-431d-ba95-1498f0e84c10/resourceGroups/rg-dev-001/providers/Microsoft.OperationalInsights/workspaces/vnetlaw"


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
    next_hop_ip    = "none"
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
