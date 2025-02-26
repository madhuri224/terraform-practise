variable "environment" {
  description = "value of the environment"
  type = string
  default = "Prod"
}

variable "resource_group_name" {
description = "Resource Group Name"
type = string
default = "myrg"
}

variable "resource_group_location" {
  description = "Resource Group Location"
  type = string
  default = "East US"
}

variable "virtual_network_name" {
  description = "value of the virtual network"
  type = string
  default = "myvnet"
}