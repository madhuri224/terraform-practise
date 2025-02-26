terraform {
  required_version = ">=1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.1.0" #
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
  subscription_id = "143e5787-4f2e-4c3c-bd65-bed636e7a3dc"
}

resource "azurerm_resource_group" "rg1" {
  name = "${var.environment}-${var.resource_group_name}"
  location = var.resource_group_location
}

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

resource "azurerm_virtual_network" "vnet1" {
  name = "${var.environment}-${var.virtual_network_name}"
  resource_group_name = azurerm_resource_group.rg1.name
  location = azurerm_resource_group.rg1.location
  address_space = ["10.0.0.0/16"]
}

output "resource_group_name" {
  description = "Resource Group Name"
  value = azurerm_resource_group.rg1.name
}

output "virtual-network-name" {
  description = "Virtual Network Name"
  value = azurerm_virtual_network.vnet1.name
}