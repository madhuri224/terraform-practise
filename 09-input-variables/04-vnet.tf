resource "azurerm_virtual_network" "vnet1" {
  name                = "${var.environment}-${var.virtual_network_name}"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  address_space       = ["10.0.0.0/16"]
}