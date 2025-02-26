resource "azurerm_storage_account" "demosa" {
  name                     = "dell${random_string.random.id}"
  resource_group_name      = azurerm_resource_group.rg1.name
  location                 = azurerm_resource_group.rg1.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = {
    environment = "Dev"
    Dept        = "IT"
  }

}

