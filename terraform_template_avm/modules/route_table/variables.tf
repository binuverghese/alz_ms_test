variable "route_table_name" {
  type        = string
  description = "The name of the route table"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group name"
}

variable "routes" {
  type        = map(any)
  description = "Route definitions"
}
