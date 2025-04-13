variable "nsg_name" {
  type        = string
  description = "Name of the NSG"
}


variable "route_table_name" {
  type        = string
  description = "Name of the route table"
}

# variables.tf

variable "location" {
  description = "The location of the resources"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "address_space" {
  description = "The address space for the virtual network"
  type        = list(string)
}

variable "routes" {
  description = "List of routes for the route table"
  type        = map(object({
    name                = string
    address_prefix      = string
    next_hop_type       = string
    next_hop_in_ip_address = string
  }))
}

variable "virtual_network_name" {
  description = "The name of the virtual network"
  type        = string
}


variable "vnet_address_space" {
  type        = list(string)
  description = "VNet address space"
}

variable "subnets" {
  type = map(object({
    name                      = string
    address_prefixes          = list(string)
    network_security_group_id = optional(string)
    route_table_id            = optional(string)
  }))
  description = "Map of subnet configurations"
}


# variable "security_rules" {
#   description = "List of security rules to be applied to the network security group"
#   type        = list(object({
#     name                       = string
#     priority                   = number
#     direction                  = string
#     access                     = string
#     protocol                   = string
#     source_port_range          = string
#     destination_port_range     = string
#     source_address_prefix      = string
#     destination_address_prefix = string
#   }))
#   default = []
# }

# Add your variable declarations here

variable "nsgrules" {
  description = "A list of NSG rules to be applied to the network security group"
  type        = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
  default = []
}


variable "security_rules" {
  description = "Map of security rules"
  type = map(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
}

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
}
variable "vnet_name" {
  description = "The name of the subnet"
  type        = string
}
