// Input variables for your Terraform configuration
subscription_id = "1e437fdf-bd78-431d-ba95-1498f0e84c10"
location        = "canadacentral"
tags = {
  environment = "development"
  created_by  = "terraform"
  owner       = "platform-team"
}

// Naming convention components
bu = "ns"              // Business Unit
region_short = "cc"    // Region short code for Canada Central
archetype = "corp"     // Architecture type
wl = "shs"            // Workload
env = "dev"           // Environment
wl_desc = "core_hub"   // Workload description

resource_group_name     = "rg-dev-015"
vnet_name               = "vnet-dev-canadacentral-015"
subnet_name             = "snet-dev-canadacentral-015"
subnet_address_prefixes = ["10.1.0.0/28"]
enable_vm_protection    = true
encryption              = false
nsg_name                = "nsg-015"
route_table_name        = "rt-navigator15"

# Expanding the VNET address space to include all subnet prefixes (10.0.x.x and 10.1.x.x)
vnet_address_space  = ["10.0.0.0/15"]
address_space_vnet1 = ["10.0.0.0/15"]

# Update data and firewall subnet prefixes to match the default in variables.tf
# Since they're already defined with 10.0.x.x prefixes in variables.tf
data_subnet_address_prefixes = ["10.0.1.0/24"]

address_space        = ["10.0.0.0/24"]
virtual_network_name = "testvnet15"

#remote_virtual_network_id = "your-remote-vnet-id" # Replace with the actual ID of the remote VNet

# Resource Groups
hub_rg_name     = "ns-cc-corp-shs-dev-core_hub-vnet-rg"
firewall_rg_name = "ns-cc-corp-shs-dev-core_hub-fw-rg"
dns_rg_name      = "ns-cc-corp-shs-dev-dns-rg"
bastion_rg_name  = "ns-cc-corp-shs-dev-bastion-rg"

# Network Security Groups
hub_nsg_name        = "ns-cc-corp-shs-dev-core_hub-nsg"
dns_bastion_nsg_name = "ns-cc-corp-shs-dev-dns_bastion-nsg"

# Route Tables
hub_route_table_name        = "ns-cc-corp-shs-dev-core_hub-rt"
dns_bastion_route_table_name = "ns-cc-corp-shs-dev-dns_bastion-rt"

# Hub VNET
hub_vnet_name        = "ns-cc-corp-shs-dev-core_hub-vnet"
hub_vnet_address_space = ["10.0.0.0/16"]
hub_subnet_name      = "snet-core_hub"
hub_subnet_address_prefixes = ["10.0.0.64/26"]  
firewall_subnet_address_prefixes = ["10.0.0.0/26"]  
express_gateway_subnet_address_prefixes = ["10.0.0.128/26"]

# DNS/Bastion VNET
dns_bastion_vnet_name = "ns-cc-corp-shs-dev-dns_bastion-vnet"
dns_bastion_vnet_address_space = ["10.1.0.0/23", "10.1.2.0/24"]
dns_resolver_inbound_subnet_address_prefixes = ["10.1.0.0/28"]
dns_resolver_outbound_subnet_address_prefixes = ["10.1.0.16/28"]
bastion_subnet_address_prefixes = ["10.1.1.0/24"]

# Firewall
firewall_name = "ns-cc-corp-shs-dev-core_hub-fw"
firewall_sku_tier = "Standard"
firewall_policy_name = "ns-cc-corp-shs-dev-core_hub-fwpp"
firewall_policy_sku_tier = "Standard"

# Firewall VNET
firewall_vnet_name = "ns-cc-corp-shs-dev-fw-vnet"
firewall_vnet_address_space = ["10.2.0.0/24"]

# DNS Resolver
dns_resolver_name = "ns-cc-corp-shs-dev-dns_resolver"

# Bastion
bastion_name = "ns-cc-corp-shs-dev-bastion"
bastion_sku = "Standard"

# VNET Peering
hub_to_dns_peering_name = "core_hub-to-dns_bastion"
dns_to_hub_peering_name = "dns_bastion-to-core_hub"

# Firewall VNET Peering
firewall_to_hub_peering_name = "fw-to-core_hub"
hub_to_firewall_peering_name = "core_hub-to-fw"

security_rules = [
  {
    name                       = "AllowHTTPSInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
    description                = "Allow HTTPS inbound traffic"
  },
  {
    name                       = "AllowBastionInbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "10.1.1.0/24"  # Updated to match the new Bastion subnet address
    description                = "Allow incoming Bastion traffic"
  }
]

routes = [
  {
    name                   = "route-to-internet"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.1.4" # Firewall IP - to be updated during deployment
  },
  {
    name           = "route-to-kms1"
    address_prefix = "20.118.99.224/32"
    next_hop_type  = "Internet"
  },
  {
    name           = "route-to-kms2"
    address_prefix = "40.83.235.53/32"
    next_hop_type  = "Internet"
  }
]

subnets = {
  "subnet11" = {
    name                      = "subnet11"
    address_prefixes          = ["10.0.1.0/24"]
    network_security_group_id = "your-nsg-id11"
    route_table_id            = "your-route-table-id11"
  }
}
backend_pools = {
  "backend-pool-1" = {
    name         = "backend-pool-1"
    ip_addresses = ["10.0.2.4", "10.0.2.5"]
  },
  "backend-pool-2" = {
    name  = "backend-pool-2"
    fqdns = ["app1.example.com", "app2.example.com"]
  }
}

http_listeners       = [
  {
    name                           = "appgw-http-listener"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "appgw-frontend-port"
    protocol                       = "Http"
    host_name                      = null
    require_sni                    = false
  }
]

dns_to_hub_name             = "dnstohub"
hub_to_dns_name             = "hubtodnspeering"

dns_vnet_id                 = "dnsvnettest"

dns_vnet_name               = "dnsvnetnametest"

hub_vnet_id                 = "hubvnettesting1"

inbound_endpoints           = [{
  name                  = "inbound-endpoint-1",
  subnet_id             = "your-inbound-subnet-id",
  private_ip_allocation = "Dynamic"
}]

outbound_endpoints          = [{
  name                  = "outbound-endpoint-1",
  subnet_id             = "your-outbound-subnet-id",
  private_ip_allocation = "Dynamic"
}]

subnet_id_inbound           = "your-inbound-subnet-id"

subnet_id_outbound          = "your-outbound-subnet-id"

gateway_ip_configuration    = {name="appgw-gateway-ip-config",subnet_id="your-appgw-subnet-id"}

frontend_ports              = [{
  name="appgw-frontend-port",port=80},{name="appgw-frontend-port-https",port=443}]

virtual_network_resource_id = "your-vnet-resource-id"
subnet_config = {
  subnet_appgw = {
    name             = "subnet-appgw"
    address_prefixes = ["10.0.1.0/24"]
  }
  subnet_firewall = {
    name             = "subnet-firewall"
    address_prefixes = ["10.0.2.0/24"]
  }
  subnet_dns = {
    name             = "subnet-dns"
    address_prefixes = ["10.0.3.0/24"]
  }
}

backend_ip_addresses = ["10.0.0.4", "10.0.0.5"]
backend_fqdns        = ["app1.example.com", "app2.example.com"]
enable_telemetry = true
nsg_id            = "testid"
route_table_id    = "routtableidtest"
subnet_id         = "subnetidtest"
