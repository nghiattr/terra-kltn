
/*-----------------------Ubuntu gitlab-sv--------------------------------------------*/

resource "azurerm_virtual_network" "myterraformnetwork-gitlab-sv" {
  name                = "myVnet-gitlab-sv"
  address_space       = ["12.0.0.0/16"]
  location            = var.resource_group_location4
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet-gitlab-sv" {
  name                 = "mySubnet-gitlab-sv"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.myterraformnetwork-gitlab-sv.name
  address_prefixes     = ["12.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip-gitlab-sv" {
  name                = "myPublicIP-gitlab-sv"
  location            = var.resource_group_location4
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

#network interface
resource "azurerm_network_interface" "myterraformnic-gitlab-sv" {
  name                = "myNIC-gitlab-sv"
  location            = var.resource_group_location4
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNicConfiguration-gitlab-sv"
    subnet_id                     = azurerm_subnet.myterraformsubnet-gitlab-sv.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip-gitlab-sv.id
  }
}

# Create (and display) an SSH key
resource "azurerm_ssh_public_key" "ssh-gitlab-sv" {
  name                = "sshkey-gitlab-sv"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.resource_group_location4
  public_key          = data.vault_generic_secret.secret-vm.data.id_rsapub
}



# Create virtual machine Linux for Jenkins-GitLab Server
resource "azurerm_linux_virtual_machine" "gitlab-sv" {
  name                  = "gitlab-sv"
  location              = var.resource_group_location4
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.myterraformnic-gitlab-sv.id]
  size                  = "Standard_B4ms"
  #Standard_B4ms

  os_disk {
    name                 = "myOsDisk-gitlab-sv"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  computer_name = "gitlab-sv"
  #admin_username                  = var.admin_username
  #admin_password                  = var.admin_password
  admin_username                  = data.vault_generic_secret.secret-vm.data.admin_username
  admin_password                  = data.vault_generic_secret.secret-vm.data.admin_password
  disable_password_authentication = false

  admin_ssh_key {
    #username   = var.admin_username
    username   = data.vault_generic_secret.secret-vm.data.admin_username
    public_key = azurerm_ssh_public_key.example_ssh.public_key
  }
  depends_on = [
    azurerm_network_interface.myterraformnic-gitlab-sv
  ]
}