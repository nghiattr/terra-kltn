
/*-----------------------Ubuntu sonar-sv--------------------------------------------*/

resource "azurerm_virtual_network" "myterraformnetwork-sonar-sv" {
  name                = "myVnet-sonar-sv"
  address_space       = ["14.0.0.0/16"]
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet-sonar-sv" {
  name                 = "mySubnet-sonar-sv"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.myterraformnetwork-sonar-sv.name
  address_prefixes     = ["14.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip-sonar-sv" {
  name                = "myPublicIP-sonar-sv"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

#network interface
resource "azurerm_network_interface" "myterraformnic-sonar-sv" {
  name                = "myNIC-sonar-sv"
  location            = var.resource_group_location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNicConfiguration-sonar-sv"
    subnet_id                     = azurerm_subnet.myterraformsubnet-sonar-sv.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip-sonar-sv.id
  }
}

# Create (and display) an SSH key
resource "azurerm_ssh_public_key" "ssh-sonar-sv" {
  name                = "sshkey-sonar-sv"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.resource_group_location
  public_key          = data.vault_generic_secret.secret-vm.data.id_rsapub
}



# Create virtual machine Linux for Jenkins-GitLab Server
resource "azurerm_linux_virtual_machine" "sonar-sv" {
  name                  = "sonar-sv"
  location              = var.resource_group_location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.myterraformnic-sonar-sv.id]
  size                  = "Standard_B2s"
  #Standard_B4ms

  os_disk {
    name                 = "myOsDisk-sonar-sv"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  computer_name = "sonar-sv"
  admin_username                  = data.vault_generic_secret.secret-vm.data.admin_username
  admin_password                  = data.vault_generic_secret.secret-vm.data.admin_password
  disable_password_authentication = false

  admin_ssh_key {
    #username   = var.admin_username
    username   = data.vault_generic_secret.secret-vm.data.admin_username
    public_key = azurerm_ssh_public_key.example_ssh.public_key
  }
  depends_on = [
    azurerm_network_interface.myterraformnic-sonar-sv
  ]
}