resource "azurerm_resource_group" "rg1" {
  name = "${var.environment}-${var.resource_group_name}"
  location = var.resource_group_location
}