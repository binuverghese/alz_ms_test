variable "subscription_id" { type = string }
variable "tenant_id"       { type = string }
variable "client_id"       { type = string }

variable "location" { type = string }
variable "resource_group_name" { type = string }
#variable "route_table_name" { type = string }
#variable "nsg_name" { type = string }
variable "vnet_name" { type = string }
variable "address_space_vnet1" { type = list(string) }
variable "dns_servers" { type = list(string) }
variable "enable_vm_protection" { type = bool }
variable "subnet_name" { type = string }
variable "subnet_address_prefixes" { type = list(string) }

# variable "routes" {
#   type = list(object({
#     name           = string
#     address_prefix = string
#     next_hop_ip    = string
#   }))
# }

 variable "security_rules" {
  description = "List of security rules for the NSG"
  type = list(object({
    name                       = string
    priority                  = number
    direction                 = string
    access                    = string
    protocol                  = string
    source_port_range         = string
    destination_port_range    = string
    source_address_prefix     = string
    destination_address_prefix = string
  }))
  default = []
}
variable "create_nsg" {
  type    = bool
  default = true  # Set based on your needs
}

variable "create_route_table" {
  type    = bool
  default = true  # Set based on your needs
}
variable "route_table_name" {
  description = "The name of the route table"
  type        = string
}

variable "nsg_name" {
  description = "The name of the Network Security Group"
  type        = string
}
variable "rg_main" {
  description = "The name of the Resource Group for main"
  type        = string
}


variable "encryption" {
  description = "Enable encryption"
  type        = bool
}
variable "flow_timeout_in_minutes" {
  description = "Flow timeout in minutes"
  type        = number
  default     = 4
}

variable "encryption_enforcement" {
  type    = string
  default = "DropUnencrypted"
}

variable "encryption_type" {
  type    = string
  default = "enabled"
}
