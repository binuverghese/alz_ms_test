resource_group_name     = "rg-dev-013"
vnet_name               = "vnet-dev-canadacentral-013"
subnet_name             = "snet-dev-canadacentral-013"
subnet_address_prefixes = ["10.1.0.0/28"]
enable_vm_protection    = true
encryption              = false
route_table_name        = "rt-navigator13"
nsg_name                = "nsg-con-0013"
address_space_vnet1     = ["10.1.0.0/24"]
rg_main                 = "rg-dev-013"

create_nsg        = true
create_route_table = true
app_gateway_name = "appgw-dev-013"

subscription_id = "1e437fdf-bd78-431d-ba95-1498f0e84c10"
client_id = "aeb81ef1-8fe3-4430-8f67-2f6d58a6dac4"
tenant_id = "72f988bf-86f1-41af-91ab-2d7cd011db47"

location        = "canadacentral" 

dns_servers             = ["10.0.2.4","10.0.2.5"]
encryption_enforcement = "DropUnencrypted"
encryption_type        = "EncryptionAtRestWithPlatformKey"

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
