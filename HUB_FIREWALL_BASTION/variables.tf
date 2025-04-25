# General variables
variable "subscription_id" {
  description = "The subscription ID to deploy the resources into"
  type        = string
}

variable "location" {
  description = "The Azure region where resources will be deployed"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    environment = "development"
    created_by  = "terraform"
    owner       = "platform-team"
  }
}

# Naming convention components
variable "bu" {
  description = "Business Unit code"
  type        = string
  default     = "ns"
}

variable "region_short" {
  description = "Region short code (e.g., cc for Canada Central)"
  type        = string
  default     = "cc"
}

variable "archetype" {
  description = "Architecture type"
  type        = string
  default     = "corp"
}

variable "wl" {
  description = "Workload name"
  type        = string
  default     = "shs"
}

variable "env" {
  description = "Environment (dev, test, prod, etc.)"
  type        = string
  default     = "prod"
}

variable "wl_desc" {
  description = "Workload description"
  type        = string
  default     = "core_hub"
}

variable "dns_wl_desc" {
  description = "DNS workload description"
  type        = string
  default     = "dns"
}

variable "bastion_wl_desc" {
  description = "Bastion workload description"
  type        = string
  default     = "bastion"
}

variable "dns_bastion_wl_desc" {
  description = "DNS/Bastion combined workload description"
  type        = string
  default     = "dns_bastion"
}

# Resource Group variables
variable "hub_rg_name" {
  description = "Name of the hub resource group"
  type        = string
  default     = null # Will be generated using naming convention
}

variable "firewall_rg_name" {
  description = "Name of the firewall resource group"
  type        = string
  default     = null # Will be generated using naming convention
}

variable "dns_rg_name" {
  description = "Name of the DNS resolver resource group"
  type        = string
  default     = null # Will be generated using naming convention
}

variable "bastion_rg_name" {
  description = "Name of the Bastion resource group"
  type        = string
  default     = null # Will be generated using naming convention
}

# Network Security Group variables
variable "hub_nsg_name" {
  description = "Name of the hub network security group"
  type        = string
  default     = null # Will be generated using naming convention
}

variable "dns_bastion_nsg_name" {
  description = "Name of the DNS/Bastion network security group"
  type        = string
  default     = null # Will be generated using naming convention
}

# Route Table variables
variable "hub_route_table_name" {
  description = "Name of the hub route table"
  type        = string
  default     = null # Will be generated using naming convention
}

variable "dns_bastion_route_table_name" {
  description = "Name of the DNS/Bastion route table"
  type        = string
  default     = null # Will be generated using naming convention
}

variable "routes" {
  description = "List of routes for the route tables"
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default = []
}

# Hub Virtual Network variables
variable "hub_vnet_name" {
  description = "Name of the hub virtual network"
  type        = string
  default     = null # Will be generated using naming convention
}

variable "hub_vnet_address_space" {
  description = "Address space for the hub virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

# Hub Subnet variables
variable "hub_subnet_name" {
  description = "Name of the hub main subnet"
  type        = string
  default     = "snet-hub"
}

variable "hub_subnet_address_prefixes" {
  description = "Address prefixes for the hub main subnet"
  type        = list(string)
  default     = ["10.0.0.0/24"]
}

variable "firewall_subnet_address_prefixes" {
  description = "Address prefixes for the Azure Firewall subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "express_gateway_subnet_address_prefixes" {
  description = "Address prefixes for the Express Gateway subnet"
  type        = list(string)
  default     = ["10.0.4.0/24"]
}

# DNS/Bastion Virtual Network variables
variable "dns_bastion_vnet_name" {
  description = "Name of the DNS/Bastion virtual network"
  type        = string
  default     = null # Will be generated using naming convention
}

variable "dns_bastion_vnet_address_space" {
  description = "Address space for the DNS/Bastion virtual network"
  type        = list(string)
  default     = ["10.0.2.0/23"]
}

variable "dns_resolver_inbound_subnet_address_prefixes" {
  description = "Address prefixes for the DNS Resolver Inbound Endpoint subnet"
  type        = list(string)
  default     = ["10.0.2.0/28"]
}

variable "dns_resolver_outbound_subnet_address_prefixes" {
  description = "Address prefixes for the DNS Resolver Outbound Endpoint subnet"
  type        = list(string)
  default     = ["10.0.2.16/28"]
}

variable "bastion_subnet_address_prefixes" {
  description = "Address prefixes for the Azure Bastion subnet"
  type        = list(string)
  default     = ["10.0.3.0/24"]
}

# Firewall Virtual Network variables
variable "firewall_vnet_name" {
  description = "Name of the firewall virtual network"
  type        = string
  default     = null # Will be generated using naming convention
}

variable "firewall_vnet_address_space" {
  description = "Address space for the firewall virtual network"
  type        = list(string)
  default     = ["10.2.0.0/24"]
}

variable "firewall_vnet_subnet_address_prefixes" {
  description = "Address prefixes for the Azure Firewall subnet in the dedicated firewall VNET"
  type        = list(string)
  default     = ["10.2.0.0/26"]  # Using a subnet within the firewall VNET address space (10.2.0.0/24)
}

# Firewall variables
variable "firewall_name" {
  description = "Name of the Azure Firewall"
  type        = string
  default     = null # Will be generated using naming convention
}

variable "firewall_sku_tier" {
  description = "SKU tier of the Azure Firewall"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.firewall_sku_tier)
    error_message = "Valid values for firewall_sku_tier are 'Standard' or 'Premium'."
  }
}

variable "firewall_policy_name" {
  description = "Name of the Azure Firewall Policy"
  type        = string
  default     = null # Will be generated using naming convention
}

variable "firewall_policy_sku_tier" {
  description = "SKU tier of the Azure Firewall Policy"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Standard", "Premium"], var.firewall_policy_sku_tier)
    error_message = "Valid values for firewall_policy_sku_tier are 'Standard' or 'Premium'."
  }
}

# DNS Resolver variables
variable "dns_resolver_name" {
  description = "Name of the DNS resolver"
  type        = string
  default     = null # Will be generated using naming convention
}

# Bastion variables
variable "bastion_name" {
  description = "Name of the Azure Bastion host"
  type        = string
  default     = null # Will be generated using naming convention
}

variable "bastion_sku" {
  description = "SKU of the Azure Bastion host"
  type        = string
  default     = "Standard"
  validation {
    condition     = contains(["Basic", "Standard"], var.bastion_sku)
    error_message = "Valid values for bastion_sku are 'Basic' or 'Standard'."
  }
}

# VNET Peering variables
variable "hub_to_dns_peering_name" {
  description = "Name of the peering from hub to DNS/Bastion VNET"
  type        = string
  default     = null # Will be generated using naming convention
}

variable "dns_to_hub_peering_name" {
  description = "Name of the peering from DNS/Bastion to hub VNET"
  type        = string
  default     = null # Will be generated using naming convention
}

variable "firewall_to_hub_peering_name" {
  description = "Name of the peering from firewall to hub VNET"
  type        = string
  default     = "firewall-to-hub"
}

variable "hub_to_firewall_peering_name" {
  description = "Name of the peering from hub to firewall VNET"
  type        = string
  default     = "hub-to-firewall"
}

variable "security_rules" {
  description = "List of security rules for NSG"
  type = list(object({
    name                                       = string
    priority                                   = number
    direction                                  = string
    access                                     = string
    protocol                                   = string
    source_port_range                         = string
    destination_port_range                     = string
    source_address_prefix                     = string
    destination_address_prefix                = string
    description                               = optional(string)
    source_port_ranges                        = optional(list(string))
    destination_port_ranges                   = optional(list(string))
    source_address_prefixes                   = optional(list(string))
    destination_address_prefixes              = optional(list(string))
    source_application_security_group_ids     = optional(list(string))
    destination_application_security_group_ids = optional(list(string))
  }))
  default = []
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see https://aka.ms/avm/telemetryinfo.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
}

# For DNS Resolver settings
variable "dns_servers" { 
  type = list(string) 
  description = "List of DNS servers to use for DNS resolution"
  default = []
}

variable "enable_vm_protection" { 
  type = bool 
  description = "Enable VM protection for all subnets in the virtual network"
  default = false
}
