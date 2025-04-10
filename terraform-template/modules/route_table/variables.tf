variable "route_table_name" {}
variable "location" {}
variable "resource_group_name" {}
variable "routes" {
  type = list(object({
    name           = string
    address_prefix = string
    next_hop_ip    = string
  }))
}
variable "subnet_id" {}

