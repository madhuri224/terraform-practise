resource "azurerm_resource_group" "rg1" {
  location = "eastus"
  name     = "dell${random_string.random.id}"

  tags = {
    environment = "Dev"
    Dept        = "IT"
  }
}