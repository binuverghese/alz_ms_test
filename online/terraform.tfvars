# Business unit, region, environment and workload description variables for name formatting
bu = "ns"                      # Business Unit
region_short = "cc"            # Region short name for Canada Central
archetype = "online"           # Archetype (online, corp, etc.)
wl = "shs"                     # Workload
env = "dev"                   # Environment (prod, dev, test, etc.)
#wl_desc = "core_hub"           # Workload description

# Resource names using the new naming standard
resource_group_name     = "ns-cc-online-shs-dev-vnet-rg"
vnet_name               = "ns-cc-online-shs-dev-vnet"
subnet_name             = "ns-cc-online-shs-dev-workload-snet"
route_table_name        = "ns-cc-online-shs-dev-rt"
nsg_name                = "ns-cc-online-shs-dev-workload-nsg"
app_gateway_name        = "ns-cc-online-shs-dev-appgateway-agw"
firewall_name           = "ns-cc-online-shs-dev-fw"
firewall_policy_name    = "ns-cc-online-shs-dev-onl-fwpp"

# Remote VNET to peer with - update the resource ID with the new naming
remote_virtual_network_id = "/subscriptions/1e437fdf-bd78-431d-ba95-1498f0e84c10/resourceGroups/ns-cc-conn-shs-dev-vnet-rg/providers/Microsoft.Network/virtualNetworks/ns-cc-conn-shs-dev-vnet"

# Cross-subscription bidirectional peering configuration
remote_subscription_id     = "1e437fdf-bd78-431d-ba95-1498f0e84c10"  
remote_tenant_id           = "72f988bf-86f1-41af-91ab-2d7cd011db47"        
remote_resource_group_name = "ns-cc-conn-shs-dev-vnet-rg"
remote_vnet_full_name      = "ns-cc-conn-shs-dev-vnet"
create_reverse_peering     = true

# Other configuration variables
rg_main                 = "ns-cc-online-shs-dev-vnet-rg"
subnet_address_prefixes = ["10.100.0.0/26"]
address_space_vnet1     = ["10.100.0.0/24"]
enable_vm_protection    = true
encryption              = false
create_nsg              = true
create_route_table      = true

location                = "canadacentral" 
subscription_id         = "28336966-cc8e-4001-8370-90e422bd0d91"  # Your subscription ID
client_id               = "1e02e9be-05a1-4337-b515-c9af9912a38a"  # Your service principal client ID
tenant_id               = "35db3582-96af-4081-a32c-7bbaa2cf3ca9"  # Your tenant ID

dns_servers             = [""] #Azure provided DNS
encryption_enforcement  = "DropUnencrypted"
encryption_type         = "EncryptionAtRestWithPlatformKey"

security_rules = [
  {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
]

# Next Hop Type for Route Table
# next_hop_type = "VirtualAppliance"

# # Routes
# routes = [
#   {
#     name           = "Internet"
#     address_prefix = "0.0.0.0/0"
#     next_hop_ip    = "10.0.0.4"
#   },
#   {
#     name           = "Hub"
#     address_prefix = "10.0.0.0/24"
#     next_hop_ip    = "10.0.0.4"
#   },
#   {
#     name           = "Spokes"
#     address_prefix = "10.1.0.0/16"
#     next_hop_ip    = "10.0.0.4"
#   },
#   {
#     name           = "On-Prem"
#     address_prefix = "192.168.0.0/16"
#     next_hop_ip    = "10.0.0.4"
#   },
#   {
#     name           = "KMS1"
#     address_prefix = "20.118.99.224/32"
#     next_hop_ip    = null
#   },
#   {
#     name           = "KMS2"
#     address_prefix = "40.83.235.53/32"
#     next_hop_ip    = null
#   }
# ]
