resource "azurerm_resource_group" "rg" {
  name = "rg-new"
  location = "eastus"
}

resource "azurerm_virtual_network" "vnet" {
  name = "vnet-new"
  address_space = ["10.0.0.0/16"]
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name 
  depends_on = [ azurerm_network_security_group.nsg ]
}

resource "azurerm_network_security_group" "nsg" {
  name = "nsg-new"
  location = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name 
}

resource "azurerm_subnet" "subnet" {
  name = "subnet-new"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes = ["10.0.1.0/24"]

}