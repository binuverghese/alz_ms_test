variable "vnet_name" {}
variable "address_space" {
  type = list(string)
}
variable "location" {}
variable "resource_group_name" {}
variable "dns_servers" {
  type = list(string)
}
variable "enable_vm_protection" {
  type = bool
}

