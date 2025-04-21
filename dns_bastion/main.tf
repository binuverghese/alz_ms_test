module "rg" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "~> 0.1"
  
  location = "canadacentral"
  name     = "rg-test-resolver-outbound-rules"
  
  enable_telemetry = true
}

module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.1"
  
  name                = "vnet-test-resolver"
  location            = module.rg.resource.location
  resource_group_name = module.rg.resource.name
  address_space       = ["10.0.0.0/16"]
  
  subnets = {
    "subnet-test-resolver-inbound" = {
      name             = "subnet-test-resolver-inbound"
      address_prefixes = ["10.0.0.0/24"]
      delegation = [
        {
          name = "Microsoft.Network.dnsResolvers"
          service_delegation = {
            name    = "Microsoft.Network/dnsResolvers"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
          }
        }
      ]
    }
    "subnet-test-resolver-outbound" = {
      name             = "subnet-test-resolver-outbound"
      address_prefixes = ["10.0.1.0/24"]
      delegation = [
        {
          name = "Microsoft.Network.dnsResolvers"
          service_delegation = {
            name    = "Microsoft.Network/dnsResolvers"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
          }
        }
      ]
    }
    "subnet-test-resolver-outbound2" = {
      name             = "subnet-test-resolver-outbound2"
      address_prefixes = ["10.0.2.0/24"]
      delegation = [
        {
          name = "Microsoft.Network.dnsResolvers"
          service_delegation = {
            name    = "Microsoft.Network/dnsResolvers"
            actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
          }
        }
      ]
    }
    "AzureBastionSubnet" = {
      name             = "AzureBastionSubnet"
      address_prefixes = ["10.0.3.0/24"]
    }
  }
  
  enable_telemetry = true
}

module "pip_bastion" {
  source  = "Azure/avm-res-network-publicipaddress/azurerm"
  version = "~> 0.1"
  
  name                = "pip-bastion"
  location            = module.rg.resource.location
  resource_group_name = module.rg.resource.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = [1, 2, 3]
  
  tags = {
    environment = "Production"
  }
  
  enable_telemetry = true
}

module "private_resolver" {
  source  = "Azure/avm-res-network-dnsresolver/azurerm"
  version = "~> 0.1"
  
  name                        = "resolver"
  resource_group_name         = module.rg.resource.name
  location                    = module.rg.resource.location
  virtual_network_resource_id = module.vnet.resource.id
  
  inbound_endpoints = {
    "inbound1" = {
      name        = "inbound1"
      subnet_id   = module.vnet.subnets["subnet-test-resolver-inbound"].resource_id
      subnet_name = "subnet-test-resolver-inbound"
    }
  }
  
  outbound_endpoints = {
    "outbound1" = {
      name        = "outbound1"
      subnet_id   = module.vnet.subnets["subnet-test-resolver-outbound"].resource_id
      subnet_name = "subnet-test-resolver-outbound"
      forwarding_ruleset = {
        "ruleset1" = {
          name = "ruleset1"
          rules = {
            "rule1" = {
              name        = "rule1"
              domain_name = "example.com."
              state       = "Enabled"
              destination_ip_addresses = {
                "10.1.1.1" = "53"
                "10.1.1.2" = "53"
              }
            },
            "rule2" = {
              name        = "rule2"
              domain_name = "example2.com."
              state       = "Enabled"
              destination_ip_addresses = {
                "10.2.2.2" = "53"
              }
            }
          }
        }
      }
    }
    "outbound2" = {
      name        = "outbound2"
      subnet_id   = module.vnet.subnets["subnet-test-resolver-outbound2"].resource_id
      subnet_name = "subnet-test-resolver-outbound2"
    }
  }
  
  enable_telemetry = true
}

module "azure_bastion" {
  source  = "Azure/avm-res-network-bastionhost/azurerm"
  version = "~> 0.1"
  
  enable_telemetry    = true
  name                = "bastion-host"
  resource_group_name = module.rg.resource.name
  location            = module.rg.resource.location
  copy_paste_enabled  = false
  file_copy_enabled   = false
  sku                 = "Standard"
  
  ip_configuration = {
    name                 = "my-ipconfig"
    subnet_id            = module.vnet.subnets["AzureBastionSubnet"].resource_id
    public_ip_address_id = module.pip_bastion.resource_id
    create_public_ip     = false
  }
  
  ip_connect_enabled     = true
  scale_units            = 4
  shareable_link_enabled = true
  tunneling_enabled      = true
  kerberos_enabled       = true

  tags = {
    environment = "development"
  }
}
