terraform {
  required_version = ">=1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.1.0" #
    }
  }
  backend "azurerm" {
    resource_group_name = "terraform-bakend"
    storage_account_name = "demoworkspacesstorage"
    container_name = "terraformstate"
    key = "terraform.tfstate"
  }
}

provider "azurerm" {
  # Configuration options
  features {}
  subscription_id = "143e5787-4f2e-4c3c-bd65-bed636e7a3dc"
}

variable "vnet_name" {}
variable "address_space" {}
variable "subnet_name" {}
variable "subnet_address" {}
variable "location" {}
variable "resource_group_name" {}

resource "azurerm_resource_group" "rg" {
  name = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name = var.vnet_name
  address_space = var.address_space
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name = var.subnet_name
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = var.subnet_address
}