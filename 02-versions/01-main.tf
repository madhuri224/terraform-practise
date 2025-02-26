terraform {
  required_version = ">=1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.1.0" #
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

resource "random_string" "random" {
  length  = 10
  special = false
  upper   = false
}

resource "azurerm_resource_group" "rg1" {
  location = "eastus"
  name     = "dell${random_string.random.id}"

  tags = {
    environment = "Prod"
    Dept        = "IT"
  }
}

resource "azurerm_virtual_network" "mynet" {
  name                = "myVnet"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

  tags = {
    environment = "Prod"
    Dept        = "IT"
  }
}

resource "azurerm_subnet" "mysubnet" {
  name                 = "mysubnet"
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.mynet.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_public_ip" "mypublicip" {
  name                = "mypublicip"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = azurerm_resource_group.rg1.location
  allocation_method   = "Static"

  tags = {
    environment = "Prod"
    Dept        = "IT"
  }
}

resource "azurerm_network_interface" "myvmnic" {
  name                = "myvmnic"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  ip_configuration {
    name                          = "myvmnicConfig"
    subnet_id                     = azurerm_subnet.mysubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.mypublicip.id
  }
  tags = {
    environment = "Prod"
    Dept        = "IT"
  }
}

resource "azurerm_network_security_group" "mynsg" {
  name                = "mynsg"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  tags = {
    environment = "Prod"
    Dept        = "IT"
  }
}

resource "azurerm_network_security_rule" "nsgrule" {
  resource_group_name         = azurerm_resource_group.rg1.name
  name                        = "Allow-ssh"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.mynsg.name
}

resource "azurerm_subnet_network_security_group_association" "mysubnet-association" {
  subnet_id                 = azurerm_subnet.mysubnet.id
  network_security_group_id = azurerm_network_security_group.mynsg.id
}

resource "azurerm_linux_virtual_machine" "mylinuxvm" {
  name                            = "mylinuxvm-1"
  computer_name                   = "devlinuxvm-1"
  location                        = azurerm_resource_group.rg1.location
  resource_group_name             = azurerm_resource_group.rg1.name
  size                            = "Standard_B1s"
  admin_username                  = "azureuser"
  admin_password                  = "Password1234"
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.myvmnic.id]
  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}