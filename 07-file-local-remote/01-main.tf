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

resource "azurerm_resource_group" "rg1" {
  location = "eastus"
  name     = "myResourceGroup"
}

resource "azurerm_virtual_network" "mynet" {
  name                = "myVnet"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

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
}

resource "azurerm_network_security_group" "mynsg" {
  name                = "mynsg"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name

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

resource "azurerm_subnet_network_security_group_association" "mysubnet-association" {
  subnet_id                 = azurerm_subnet.mysubnet.id
  network_security_group_id = azurerm_network_security_group.mynsg.id
}

resource "azurerm_linux_virtual_machine" "mylinuxvm" {
  name                = "mylinuxvm-1"
  computer_name       = "devlinuxvm-1"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  size                = "Standard_B1s"
  admin_username      = "azureadmin"
  admin_ssh_key {
    username   = "azureadmin"
    public_key = file("C:\\Users\\krishna\\.ssh\\id_rsa.pub") #Public Key to VM
  }

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
  provisioner "local-exec" {
    command = "echo ${azurerm_linux_virtual_machine.mylinuxvm.public_ip_address} > public_ip.txt"
  }
}


resource "null_resource" "file_copy_remote_exec" {
  provisioner "file" {
    source      = "apache-install.sh"
    destination = "/tmp/apache-install.sh"
    connection {
      type        = "ssh"
      host        = azurerm_public_ip.mypublicip.ip_address
      user        = "azureadmin"
      private_key = file("C:\\Users\\Bala\\.ssh\\id_rsa")
    }
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = azurerm_public_ip.mypublicip.ip_address
      user        = "azureadmin"
      private_key = file("C:\\Users\\Bala\\.ssh\\id_rsa")
    }

    inline = [
      "sudo chmod +x /tmp/apache-install.sh",
      "sudo /tmp/apache-install.sh"
    ]
  }
  depends_on = [azurerm_linux_virtual_machine.mylinuxvm]
}

