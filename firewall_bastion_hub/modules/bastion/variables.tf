variable "name" {
  description = "Name of the Bastion host"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "public_ip_id" {
  description = "ID of the public IP"
  type        = string
}

variable "subnet_id" {
  description = "ID of the AzureBastionSubnet"
  type        = string
}

variable "dns_name" {
  description = "Optional DNS name label"
  type        = string
  default     = null
}

variable "ip_connect_enabled" {
  description = "Enable IP-based connection"
  type        = bool
  default     = true
}

variable "scale_units" {
  description = "Number of scale units"
  type        = number
  default     = 2
}

variable "tunneling_enabled" {
  description = "Enable tunneling"
  type        = bool
  default     = true
}

variable "kerberos_enabled" {
  description = "Enable Kerberos authentication"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to the Bastion host"
  type        = map(string)
  default     = {}
}
