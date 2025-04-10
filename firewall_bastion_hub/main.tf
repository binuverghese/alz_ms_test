terraform {
  required_version = ">= 1.9, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.116.0, < 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "1e437fdf-bd78-431d-ba95-1498f0e84c10"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-dev-007"
  location = "Canada Central"
}

module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
}

# Hub VNet with subnets (Firewall, DNS Resolver, App)
module "hub_vnet" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  name                = "hub-vnet"
  enable_telemetry    = false
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]

  subnets = {
    AzureFirewallSubnet = {
      name             = "AzureFirewallSubnet"
      address_prefixes = ["10.0.1.0/24"]
    },
    InboundEndpoint = {
      name             = "InboundEndpoint"
      address_prefixes = ["10.0.2.0/28"]
    },
    OutboundEndpoint = {
      name             = "OutboundEndpoint"
      address_prefixes = ["10.0.2.16/28"]
    }
  }
}

# Public IP for Azure Firewall
resource "azurerm_public_ip" "firewall_pip" {
  name                = "firewall-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [1, 2, 3]
}

# Firewall Policy
module "fw_policy" {
  source              = "Azure/avm-res-network-firewallpolicy/azurerm"
  name                = "firewall-policy"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Azure Firewall
module "firewall" {
  source              = "Azure/avm-res-network-azurefirewall/azurerm"
  name                = "hub-firewall"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  firewall_sku_tier   = "Standard"
  firewall_sku_name   = "AZFW_VNet"
  firewall_policy_id  = module.fw_policy.resource_id

  firewall_ip_configuration = [
    {
      name                 = "ipconfig"
      subnet_id            = module.hub_vnet.subnets["AzureFirewallSubnet"].resource_id
      public_ip_address_id = azurerm_public_ip.firewall_pip.id
    }
  ]
}

# DNS Resolver with Firewall private IP as destination
module "private_resolver" {
  source                      = "Azure/avm-res-network-dnsresolver/azurerm"
  resource_group_name         = azurerm_resource_group.rg.name
  name                        = "resolver"
  virtual_network_resource_id = module.hub_vnet.resource_id
  location                    = azurerm_resource_group.rg.location
  inbound_endpoints = {
    inbound1 = {
      name        = "inbound1"
      subnet_name = module.hub_vnet.subnets["InboundEndpoint"].name
    }
  }
  outbound_endpoints = {
    outbound1 = {
      name        = "outbound1"
      subnet_name = module.hub_vnet.subnets["OutboundEndpoint"].name
      forwarding_ruleset = {
        ruleset1 = {
          name = "ruleset1"
          rules = {
            rule1 = {
              name        = "rule1"
              domain_name = "example.com."
              state       = "Enabled"
              destination_ip_addresses = {
                (module.firewall.ip_configurations[0].private_ip_address) = "53"
              }
            }
          }
        }
      }
    }
  }
  depends_on = [module.firewall]
}

# Bastion VNet and subnet
module "bastion_vnet" {
  source              = "Azure/avm-res-network-virtualnetwork/azurerm"
  version             = "~> 0.2"
  name                = "bastion-vnet"
  enable_telemetry    = false
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.1.0.0/24"]
  subnets = {
    AzureBastionSubnet = {
      name             = "AzureBastionSubnet"
      address_prefixes = ["10.1.0.0/24"]
    }
  }
}

# Bastion Public IP
resource "azurerm_public_ip" "bastion_ip" {
  allocation_method   = "Static"
  location            = azurerm_resource_group.rg.location
  name                = "bastion-public-ip"
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  zones               = [1, 2, 3]
}

# Bastion Host
module "azure_bastion" {
  source              = "Azure/avm-res-network-bastionhost/azurerm"
  name                = module.naming.bastion_host.name_unique
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  copy_paste_enabled  = true
  file_copy_enabled   = false
  sku                 = "Standard"
  ip_configuration = {
    name                 = "bastion-ipconfig"
    subnet_id            = module.bastion_vnet.subnets["AzureBastionSubnet"].resource_id
    public_ip_address_id = azurerm_public_ip.bastion_ip.id
    create_public_ip     = false
  }
  ip_connect_enabled     = true
  scale_units            = 2
  shareable_link_enabled = true
  tunneling_enabled      = true
  kerberos_enabled       = true
  tags = {
    environment = "dev"
  }
}

# Peering: DNS <-> Hub
resource "azurerm_virtual_network_peering" "hub_to_dns" {
  name                         = "hub-to-dns"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = module.hub_vnet.name
  remote_virtual_network_id    = module.hub_vnet.resource_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "dns_to_hub" {
  name                         = "dns-to-hub"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = module.hub_vnet.name
  remote_virtual_network_id    = module.hub_vnet.resource_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

# Peering: Bastion <-> Hub
resource "azurerm_virtual_network_peering" "bastion_to_hub" {
  name                         = "bastion-to-hub"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = module.bastion_vnet.name
  remote_virtual_network_id    = module.hub_vnet.resource_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

resource "azurerm_virtual_network_peering" "hub_to_bastion" {
  name                         = "hub-to-bastion"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = module.hub_vnet.name
  remote_virtual_network_id    = module.bastion_vnet.resource_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}
