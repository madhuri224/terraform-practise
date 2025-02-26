terraform {
  required_providers {
    azurerm = {
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
  subscription_id = "143e5787-4f2e-4c3c-bd65-bed636e7a3dc"
}

resource "azurerm_resource_group" "rg1" {
  for_each = {
    "dc1apps" = "eastus"
    "dc2apps" = "westus"
    "dc3apps" = "centralus"
  }
  name     = "${each.key}-rg"
  location = each.value
}