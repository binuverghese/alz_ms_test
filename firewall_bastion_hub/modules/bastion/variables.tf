variable "name" {
  type        = string
  description = "Name of the Bastion host"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "public_ip_id" {
  type        = string
  description = "ID of the Bastion public IP"
}

variable "subnet_id" {
  type        = string
  description = "ID of the AzureBastionSubnet"
}

variable "dns_name" {
  type        = string
  default     = null
  description = "DNS name label"
}

variable "scale_units" {
  type        = number
  default     = 2
}

variable "ip_connect_enabled" {
  type        = bool
  default     = true
}

variable "tunneling_enabled" {
  type        = bool
  default     = true
}

variable "kerberos_enabled" {
  type        = bool
  default     = false
}

variable "copy_paste_enabled" {
  type        = bool
  default     = true
}

variable "file_copy_enabled" {
  type        = bool
  default     = true
}

variable "tags" {
  type        = map(string)
  default     = {}
}
