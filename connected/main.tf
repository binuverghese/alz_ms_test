module "rg_main" {
  source  = "Azure/avm-res-resources-resourcegroup/azurerm"
  version = "0.2.1"

  name     = var.resource_group_name
  location = var.location
}

module "nsg" {
  source  = "Azure/avm-res-network-networksecuritygroup/azurerm"
  version = "~> 0.1"

  name                = var.nsg_name
  location            = var.location
  resource_group_name = module.rg_main.name
  
  security_rules = {
    for idx, rule in var.security_rules : rule.name => {
      name                       = rule.name
      priority                   = rule.priority
      direction                  = rule.direction
      access                     = rule.access
      protocol                   = rule.protocol
      source_port_range          = rule.source_port_range
      destination_port_range     = rule.destination_port_range
      source_address_prefix      = rule.source_address_prefix
      destination_address_prefix = rule.destination_address_prefix
    }
  }

  depends_on = [module.rg_main]
}

# Virtual network without subnets
module "vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "~> 0.1"

  name                = var.vnet_name
  location            = var.location
  resource_group_name = module.rg_main.name
  address_space       = var.address_space_vnet1
  
  enable_vm_protection = var.enable_vm_protection
  
  encryption = {
    enabled     = var.encryption
    enforcement = var.encryption_enforcement
    type        = var.encryption_type
  }
  
  flow_timeout_in_minutes = var.flow_timeout_in_minutes
  
  # Empty subnets - we'll create separately
  subnets = {}
}

# Create subnet separately
resource "azurerm_subnet" "main" {
  name                 = var.subnet_name
  resource_group_name  = module.rg_main.name
  virtual_network_name = module.vnet.name
  address_prefixes     = var.subnet_address_prefixes
  
  #private_link_endpoint_network_policies_enabled = true
}

# Explicit subnet-NSG association
resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = module.nsg.resource.id
  
  depends_on = [azurerm_subnet.main, module.nsg]
}
