terraform {
  required_version = ">= 1.9, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4"
    }
    modtm = {
      source  = "Azure/modtm"
      version = "~> 0.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  subscription_id = "1e437fdf-bd78-431d-ba95-1498f0e84c10"

  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

 module "regions" {
   source  = "Azure/regions/azurerm"
   version = "~> 0.3"
 }


 module "naming" {
   source  = "Azure/naming/azurerm"
   version = "~> 0.3"
 }

 resource "azurerm_resource_group" "this" {
   location = var.location
   name     = var.resource_group_name
 }

data "http" "public_ip" {
  method = "GET"
  url    = "http://api.ipify.org?format=json"
}



module "nsg" {
  #source              = "Azure/avm-res-network-networksecuritygroup/azurerm"
  
  source                = "./modules/nsg"
  #version             = "~> 0.1"
  name                = var.nsg_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  # Pass security rules as a variable if supported by the module
  security_rules = var.security_rules
  }


module "route_table" {
  source              = "./modules/route_table"
  route_table_name    = var.route_table_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  routes              = var.routes
}


module "vnet" {
  source               = "./modules/vnet"
  virtual_network_name = var.vnet_name
  resource_group_name  = azurerm_resource_group.this.name
  location             = var.location
  address_space        = var.vnet_address_space
  dns_servers = ["10.0.0.4", "10.0.0.5"]

  subnets = {
    subnet1 = {
      name                             = "subnet1"
      address_prefixes                 = ["10.0.1.0/24"]
      default_outbound_access_enabled = false
      network_security_group_id       = module.nsg.id
      route_table_id                  = module.route_table.id

    }
  }
}
