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
variable "app_gateway_name" {
  description = "The name of the Application Gateway"
  type        = string
  default     = "appgw-dev-013"
}

variable "remote_virtual_network_id" {
  description = "The full resource ID of the remote virtual network to peer with"
  type        = string
  default     = null
}

variable "remote_vnet_name" {
  description = "The name of the remote virtual network to peer with"
  type        = string
  default     = "spoke_hub-vnet"
}

# Variables for cross-subscription VNET peering
variable "remote_subscription_id" {
  description = "Subscription ID where the remote VNET is located"
  type        = string
  default     = null
}

variable "remote_tenant_id" {
  description = "Tenant ID for the remote subscription (if different from primary)"
  type        = string
  default     = null
}

variable "create_reverse_peering" {
  description = "Whether to create the reverse peering from remote VNET to local VNET"
  type        = bool
  default     = false
}

variable "remote_resource_group_name" {
  description = "Resource group name where the remote VNET is located"
  type        = string
  default     = null
}

variable "remote_vnet_full_name" {
  description = "Full name of the remote VNET"
  type        = string
  default     = null
}

# Variables for naming convention components
variable "bu" {
  description = "Business unit prefix for resource naming (e.g., ns)"
  type        = string
  default     = "ns"
}

variable "region_short" {
  description = "Short region code for resource naming (e.g., cc for Canada Central)"
  type        = string
  default     = "cc"
}

variable "archetype" {
  description = "Archetype for resource naming (e.g., online, corp)"
  type        = string
  default     = "online"
}

variable "wl" {
  description = "Workload identifier for resource naming (e.g., shs)"
  type        = string
  default     = "shs"
}

variable "env" {
  description = "Environment for resource naming (e.g., prod, dev, test)"
  type        = string
  default     = "dev"
}

variable "wl_desc" {
  description = "Workload description for resource naming (e.g., core_hub)"
  type        = string
  default     = "core_hub"
}

variable "firewall_name" {
  description = "The name of the Azure Firewall"
  type        = string
  default     = ""
}

variable "firewall_policy_name" {
  description = "The name of the Azure Firewall Policy"
  type        = string
  default     = ""
}
