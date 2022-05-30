
/*-----------------------CentOS nexus--------------------------------------------*/

resource "azurerm_virtual_network" "myterraformnetwork-nexus" {
  name                = "myVnet-nexus"
  address_space       = ["11.0.0.0/16"]
  location            = var.resource_group_location5
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet-nexus" {
  name                 = "mySubnet-nexus"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.myterraformnetwork-nexus.name
  address_prefixes     = ["11.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip-nexus" {
  name                = "myPublicIP-nexus"
  location            = var.resource_group_location5
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

#network interface
resource "azurerm_network_interface" "myterraformnic-nexus" {
  name                = "myNIC-nexus"
  location            = var.resource_group_location5
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNicConfiguration-nexus"
    subnet_id                     = azurerm_subnet.myterraformsubnet-nexus.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip-nexus.id
  }
}

# Create (and display) an SSH key
resource "azurerm_ssh_public_key" "ssh-nexus" {
  name                = "sshkey-nexus"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.resource_group_location5
  public_key          = data.vault_generic_secret.secret-vm.data.id_rsapub
}

#Create virtual machine nexus nexus
resource "azurerm_linux_virtual_machine" "nexus-vm" {
  name                  = "nexus-vm"
  location              = var.resource_group_location5
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.myterraformnic-nexus.id]
  size                  = "Standard_B4ms"

  os_disk {
    name                 = "myOsDisk-nexus"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }


  computer_name = "nexus-vm"
  #admin_username                  = var.admin_username
  #admin_password                  = var.admin_password
  admin_username                  = data.vault_generic_secret.secret-vm.data.admin_username
  admin_password                  = data.vault_generic_secret.secret-vm.data.admin_password
  disable_password_authentication = false

  admin_ssh_key {
    #username   = var.admin_username
    username   = data.vault_generic_secret.secret-vm.data.admin_username
    public_key = azurerm_ssh_public_key.ssh-nexus.public_key
  }
  depends_on = [
    azurerm_network_interface.myterraformnic-nexus
  ]

}