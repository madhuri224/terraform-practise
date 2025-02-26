terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.18.0"
    }
  }
  backend "azurerm" {
    resource_group_name = "myrg-1"
    storage_account_name = "demoazurencplstorage"
    container_name = "azureterraformstate"
    key = "terraform.tfstate"
  }
}

provider "azurerm" {
  # Configuration options
  features {}
  subscription_id = "202d4be6-e0dd-4b9e-84b7-e235d53271a8"
}

resource "azurerm_resource_group" "rg1" {
  location = "eastus"
  name     = "myResourceGroup"

  tags = {
    environment = "Prod"
    Dept        = "IT"
  }
}

resource "azurerm_resource_group" "rg2" {
  location = "eastus"
  name     = "myResourceGroup1"

  tags = {
    environment = "Dev"
    Dept        = "IT"
  }
}

resource "azurerm_resource_group" "rg3" {
  location = "eastus"
  name     = "myResourceGroup2"

  tags = {
    environment = "UAT"
    Dept        = "IT"
  }
}