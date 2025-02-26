
terraform {
  required_version = ">=1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.1.0" #
    }
  }
}

provider "azurerm" {
  # Configuration options
  features {}
  subscription_id = "143e5787-4f2e-4c3c-bd65-bed636e7a3dc"
}

data "azurerm_resource_group" "rg1" {
  name = "azkeydemovault"
}

data "azurerm_key_vault" "azkey" {
  name = "azkeydemovault1"
  resource_group_name = data.azurerm_resource_group.rg1.name  
  }

data "azurerm_key_vault_secret" "vm_password" {
  name = "azureadmin"
  key_vault_id = data.azurerm_key_vault.azkey.id
}

data "azurerm_public_ip" "pip" {
  name = "pip"
  resource_group_name = data.azurerm_resource_group.rg1.name   
}

resource "azurerm_virtual_network" "mynet" {
  name                = "myVnet"
  address_space       = ["10.10.0.0/16"]
  location            = data.azurerm_resource_group.rg1.location
  resource_group_name = data.azurerm_resource_group.rg1.name

}


resource "azurerm_subnet" "mysubnet" {
  name                 = "mysubnet"
  resource_group_name  = data.azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.mynet.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_network_security_group" "mynsg" {
  name                = "mynsg"
  location            = data.azurerm_resource_group.rg1.location
  resource_group_name = data.azurerm_resource_group.rg1.name

  security_rule {

    name                       = "Allow-ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-Http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_interface" "myvmnic" {
  name                = "myvmnic"
  location            = data.azurerm_resource_group.rg1.location
  resource_group_name = data.azurerm_resource_group.rg1.name
  ip_configuration {
    name                          = "myvmnicConfig"
    subnet_id                     = azurerm_subnet.mysubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = data.azurerm_public_ip.pip.id
  }
}

resource "azurerm_subnet_network_security_group_association" "mysubnet-association" {
  subnet_id                 = azurerm_subnet.mysubnet.id
  network_security_group_id = azurerm_network_security_group.mynsg.id
}

resource "azurerm_linux_virtual_machine" "mylinuxvm" {
  name                = "mylinuxvm-1"
  computer_name       = "devlinuxvm-1"
  location            = data.azurerm_resource_group.rg1.location
  resource_group_name = data.azurerm_resource_group.rg1.name
  size                = "Standard_B1s"
  admin_username      = "azureadmin"
  admin_password = data.azurerm_key_vault_secret.vm_password.value
  disable_password_authentication = false
  

  network_interface_ids = [azurerm_network_interface.myvmnic.id]
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

output "pip" {
  description = "PublicIP"
  value = data.azurerm_public_ip.pip.ip_address
}


