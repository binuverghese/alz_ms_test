terraform {
  required_version = ">= 1.9, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.74"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "~> 1.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
#backend "azurerm" {
    #resource_group_name   = "TestVM"   # The RG where state is stored
    #storage_account_name  = "tfstatecse"     # The storage account name
    #container_name        = "terraform"               # The container name
    #key                   = "terraform.tfstate"     # The name of the state file
  #}
}

provider "azurerm" {
  features {}
   use_oidc        = true  #
   subscription_id = "1e437fdf-bd78-431d-ba95-1498f0e84c10"
   tenant_id       = "35db3582-96af-4081-a32c-7bbaa2cf3ca9"
   client_id       = "879f6aaa-ccb8-47de-9311-50a1c516a55a"
}

provider "azapi" {
  
}

# Resource Group
resource "azurerm_resource_group" "this" {
  location = var.location
  name     = var.resource_group_name
}

# Route Table (UDR) - Parameterized
resource "azurerm_route_table" "this" {
  location            = var.location
  name                = var.route_table_name
  resource_group_name = var.resource_group_name

  dynamic "route" {
    for_each = var.routes
    content {
      name                   = route.value.name
      address_prefix         = route.value.address_prefix
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = route.value.next_hop_ip
    }
  }
}

# Network Security Group (NSG)
resource "azurerm_network_security_group" "nsg" {
  location            = var.location
  name                = var.nsg_name
  resource_group_name = var.resource_group_name

  security_rule {
    access                     = "Deny"
    destination_address_prefix = "*"
    destination_port_range     = "*"
    direction                  = "Inbound"
    name                       = "DenyAllInbound"
    priority                   = 4096
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }
}

# Virtual Network
module "vnet1" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = var.vnet_name
  address_space       = var.address_space_vnet1

  dns_servers = {
    dns_servers = toset(var.dns_servers)
  }

  enable_vm_protection = var.enable_vm_protection
}

# Subnet
module "subnet1" {
  source = "Azure/avm-res-network-virtualnetwork/azurerm//modules/subnet"

  virtual_network = {
    resource_id = module.vnet1.resource_id
  }

  address_prefixes = var.subnet_address_prefixes
  name             = var.subnet_name
}

# Ensure the Subnet module outputs `resource_id`
output "subnet_id" {
  value = module.subnet1.resource_id
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
