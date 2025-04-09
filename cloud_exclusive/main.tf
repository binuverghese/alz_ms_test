terraform {
  required_version = ">= 1.9, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.74"
    }
  }
}

backend "azurerm" {
    resource_group_name   = "rg-dev-001"   # The RG where state is stored
    storage_account_name  = "tfstatedemonew"     # The storage account name
    container_name        = "tfstate"               # The container name
    key                   = "terraform.tfstate"     # The name of the state file
  }


provider "azurerm" {
  features {}
   #use_msi        = true  #
   subscription_id = "1e437fdf-bd78-431d-ba95-1498f0e84c10"
   tenant_id       = "35db3582-96af-4081-a32c-7bbaa2cf3ca9"
   client_id       = "ec375efa-27ef-4631-834f-05ddec12a417"
}

# Resource Group
resource "azurerm_resource_group" "this" {
  location = var.location
  name     = var.resource_group_name
}

resource "azurerm_route_table" "this" {
  location            = var.location
  name                = var.route_table_name
  resource_group_name = var.resource_group_name

  dynamic "route" {
    for_each = var.routes
    content {
      name                   = route.value.name
      address_prefix         = route.value.address_prefix
      next_hop_type          = route.value.next_hop_ip != null ? "VirtualAppliance" : "Internet"
      next_hop_in_ip_address = route.value.next_hop_ip
    }
  }
}


# Network Security Group (NSG) - Parameterized `security_rule`
resource "azurerm_network_security_group" "nsg" {
  location            = var.location
  name                = var.nsg_name
  resource_group_name = var.resource_group_name

  dynamic "security_rule" {
    for_each = var.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_address_prefix      = security_rule.value.source_address_prefix
      source_port_range          = security_rule.value.source_port_range
      destination_address_prefix = security_rule.value.destination_address_prefix
      destination_port_range     = security_rule.value.destination_port_range
    }
  }
}

# Enable VNET Flow Logs
resource "azurerm_monitor_diagnostic_setting" "vnet_flow_logs" {
  name                       = "vnet-flow-logs"
  target_resource_id         = module.vnet1.resource_id
  storage_account_id         = var.storage_account_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  log {
    category = "NetworkSecurityGroupRuleCounter"
    enabled  = true
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Virtual Network Module
module "vnet1" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.vnet_name
  address_space       = var.address_space_vnet1
  enable_vm_protection = var.enable_vm_protection

  dns_servers = {
    dns_servers = toset(var.dns_servers)
  }
}

# Subnet Module
module "subnet1" {
  source = "Azure/avm-res-network-virtualnetwork/azurerm//modules/subnet"

  virtual_network = {
    resource_id = module.vnet1.resource_id
  }

  address_prefixes = var.subnet_address_prefixes
  name             = var.subnet_name
}

# Associate Route Table (UDR) with Subnet
resource "azurerm_subnet_route_table_association" "subnet_rt" {
  subnet_id      = module.subnet1.resource_id
  route_table_id = azurerm_route_table.this.id
}

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "subnet_nsg" {
  subnet_id                 = module.subnet1.resource_id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
