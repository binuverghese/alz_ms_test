variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "virtual_network_id" {
  type = string
}

variable "inbound_endpoints" {
  type = map(any)
}

variable "outbound_endpoints" {
  type = map(any)
}
