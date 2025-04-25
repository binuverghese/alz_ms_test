variable "subscription_id" { type = string }
variable "tenant_id"       { type = string }
variable "client_id"       { type = string }

variable "location" { type = string }

variable "resource_group_name" { 
  type = string
  default = "" # Will be overridden by local.rg_name in main.tf 
}

variable "vnet_name" { 
  type = string
  default = "" # Will be overridden by local.vnet_name in main.tf 
}

variable "address_space_vnet1" { type = list(string) }
variable "dns_servers" {

  description = "List of DNS server IP addresses for the virtual network"

  type        = list(string)

  default     = []

}
variable "enable_vm_protection" { type = bool }

variable "subnet_name" { 
  type = string
  default = "" # Will be overridden by local.subnet_name in main.tf 
}

variable "subnet_address_prefixes" { type = list(string) }

// Naming components
variable "business_unit" {
  description = "Business unit abbreviation (e.g., 'ns')"
  type        = string
  default     = "ns"
}

variable "region_short" {
  description = "Short region name (e.g., 'cc' for canadacentral)"
  type        = string
  default     = "cc"
}

variable "archetype" {
  description = "Architecture type (e.g., 'conn', 'corp')"
  type        = string
  default     = "conn"
}

variable "workload" {
  description = "Workload name (e.g., 'shs')"
  type        = string
  default     = "shs"
}

variable "environment" {
  description = "Environment name (e.g., 'dev', 'prod')"
  type        = string
  default     = "dev"
}

variable "workload_description" {
  description = "Workload description (e.g., 'core_hub')"
  type        = string
  default     = "core_hub"
}

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
  default     = "" # Will be overridden by local.rt_name in main.tf
}

variable "nsg_name" {
  description = "The name of the Network Security Group"
  type        = string
  default     = "" # Will be overridden by local.nsg_name in main.tf
}

variable "rg_main" {
  description = "The name of the Resource Group for main"
  type        = string
  default     = "" # Will be overridden by local.rg_name in main.tf
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

variable "remote_virtual_network_id" {
  description = "The resource ID of the remote virtual network for peering. Set to null to disable peering."
  type        = string
  default     = null
}
