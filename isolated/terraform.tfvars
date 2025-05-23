# Naming components - these combine to create all resource names
business_unit        = "ns"
region_short         = "cc"
archetype            = "iso"
workload             = "shs"
environment          = "dev"
#workload_description = "core_hub"

# Location and network settings
location                = "canadacentral"
subnet_address_prefixes = ["172.0.0.0/24"] # Updated to AzureFirewallSubnet
address_space_vnet1     = ["172.0.0.0/24", "172.0.2.0/23", "172.1.0.0/16", "172.100.0.0/16"] # Updated for all network spaces
enable_vm_protection    = true
encryption              = false
create_nsg              = true
create_route_table      = true

# Authentication details
subscription_id         = "1e437fdf-bd78-431d-ba95-1498f0e84c10"
client_id               = "aeb81ef1-8fe3-4430-8f67-2f6d58a6dac4"
tenant_id               = "72f988bf-86f1-41af-91ab-2d7cd011db47"

# Network configuration
dns_servers             = ["172.0.2.4"] # Updated DNS server
encryption_enforcement  = "DropUnencrypted"
encryption_type         = "EncryptionAtRestWithPlatformKey"

# Security rules
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

#remote_virtual_network_id = "/subscriptions/1e437fdf-bd78-431d-ba95-1498f0e84c10/resourceGroups/ns-cc-online-shs-dev-core_hub-vnet-rg/providers/Microsoft.Network/virtualNetworks/ns-cc-online-shs-dev-core_hub-vnet"

# Routes configuration based on provided requirements
routes = [
  {
    name           = "Internet"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_ip    = "172.0.0.4"
  },
  {
    name           = "Hub"
    address_prefix = "172.0.0.0/24"
    next_hop_type  = "VirtualAppliance"
    next_hop_ip    = "172.0.0.4"
  },
  {
    name           = "Spokes"
    address_prefix = "172.1.0.0/16"
    next_hop_type  = "VirtualAppliance"
    next_hop_ip    = "172.0.0.4"
  },
  {
    name           = "KMS1"
    address_prefix = "20.118.99.224/32"
    next_hop_type  = "Internet"
    next_hop_ip    = null
  },
  {
    name           = "KMS2"
    address_prefix = "40.83.235.53/32"
    next_hop_type  = "Internet"
    next_hop_ip    = null
  }
]
