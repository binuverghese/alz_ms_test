# Single naming prefix following BU-Region-Archetype-WL-Env-WLDesc format
naming_prefix = "ns-cc-cloud-shs-dev"

# Azure authentication
subscription_id = "1e437fdf-bd78-431d-ba95-1498f0e84c10"
client_id = "aeb81ef1-8fe3-4430-8f67-2f6d58a6dac4"
tenant_id = "72f988bf-86f1-41af-91ab-2d7cd011db47"

# Location
location = "canadacentral"

# Network configuration
address_space_vnet = ["10.1.1.0/24"]
subnet_address_prefixes = ["10.1.1.0/28"]
dns_servers = ["10.0.2.4"]

# Network features
enable_vm_protection = true
encryption = false
encryption_enforcement = "DropUnencrypted"
encryption_type = "EncryptionAtRestWithPlatformKey"

# Security configuration
create_nsg = true
create_route_table = true

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

# VNet peering configuration 
# Set enable_vnet_peering to true to enable VNet peering
enable_vnet_peering = false

# Example of peer VNets configuration - update with actual values when needed
peer_vnets = [
  # {
  #   name                       = "peer-to-spoke1"
  #   remote_vnet_name           = "ns-cc-corp-shs-prod-spoke1-vnet"
  #   remote_vnet_id             = "/subscriptions/subscription_id/resourceGroups/ns-cc-corp-shs-prod-spoke1-vnet-rg/providers/Microsoft.Network/virtualNetworks/ns-cc-corp-shs-prod-spoke1-vnet"
  #   remote_resource_group_name = "ns-cc-corp-shs-prod-spoke1-vnet-rg"
  #   allow_virtual_network_access = true
  #   allow_forwarded_traffic     = true
  #   allow_gateway_transit       = false
  #   use_remote_gateways         = false
  # },
  # {
  #   name                       = "peer-to-spoke2"
  #   remote_vnet_name           = "ns-cc-corp-shs-prod-spoke2-vnet"
  #   remote_vnet_id             = "/subscriptions/subscription_id/resourceGroups/ns-cc-corp-shs-prod-spoke2-vnet-rg/providers/Microsoft.Network/virtualNetworks/ns-cc-corp-shs-prod-spoke2-vnet"
  #   remote_resource_group_name = "ns-cc-corp-shs-prod-spoke2-vnet-rg"
  #   allow_virtual_network_access = true
  #   allow_forwarded_traffic     = true
  #   allow_gateway_transit       = false
  #   use_remote_gateways         = false
  # }
]

# # Routes - commented out as it's not used in the current configuration
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
	
#     {
#     name           = "KMS1"
#     address_prefix = "20.118.99.224/32"
#     next_hop_ip    = null
#   },
# {
#     name           = "KMS2"
#     address_prefix = "40.83.235.53/32"
#     next_hop_ip    = null
#   }
# ]
