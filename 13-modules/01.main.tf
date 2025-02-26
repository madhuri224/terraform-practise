terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.18.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
  subscription_id = "143e5787-4f2e-4c3c-bd65-bed636e7a3dc"
}

