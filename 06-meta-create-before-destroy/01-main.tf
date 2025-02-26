terraform {
  required_providers {  
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.18.0"
    }
  }
}
provider "azurerm" {
  # Configuration options
  features {}
  subscription_id = "143e5787-4f2e-4c3c-bd65-bed636e7a3dc"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-new"
  location = "East US"
}
resource "azurerm_network_security_group" "nsg" {
  name                = "my-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_virtual_network" "vnet" {
  name          = "vnet-name"
  address_space = ["10.0.0.0/16"]
  location      = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  depends_on = [azurerm_network_security_group.nsg]
  tags = {
    Env = "Prod"
    Dept = "IT"
  }
  lifecycle {
    ignore_changes = [ 
        tags,
     ]
  }
  
}