resource "azurerm_resource_group" "rg1" {
count = 3
  location = "eastus"
  name     = "rg-${count.index+1}" #0,1,2--rg-1,rg-2,rg-3

  tags = {
    environment = "Prod"
    Dept        = "IT"
  }
}

resource "azurerm_virtual_network" "vnet1" {
    count = 3
  name                = "vnet1-${count.index+1}"
  resource_group_name = azurerm_resource_group.rg1[count.index].name
  location            = azurerm_resource_group.rg1[count.index].location
  address_space       = [ "10.${count.index}.0.0/16" ]
}

resource "azurerm_subnet" "subnet" {
  count= 9
  name = "subnet-${floor(count.index / 3) +1 }-${count.index % 3 + 1}"
  resource_group_name = azurerm_resource_group.rg1[floor(count.index / 3)].name
  virtual_network_name = azurerm_virtual_network.vnet1[floor(count.index / 3)].name
  address_prefixes = ["10.${floor(count.index / 3)}.${count.index % 3 +1}.0/24"]

}


#subnet-1-1  10.0.1.0/24
#subnet-1-2  10.0.2.0/24
#subnet-1-3  10.0.3.0/24
#subnet-2-1  10.1.1.0/24