
/*-----------------------CentOS AWX--------------------------------------------*/

resource "azurerm_virtual_network" "myterraformnetwork-ansible" {
  name                = "myVnet-ansible"
  address_space       = ["10.0.0.0/16"]
  location            = var.resource_group_location3
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet-ansible" {
  name                 = "mySubnet-ansible"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.myterraformnetwork-ansible.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip-ansible" {
  name                = "myPublicIP-ansible"
  location            = var.resource_group_location3
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

#network interface
resource "azurerm_network_interface" "myterraformnic-ansible" {
  name                = "myNIC-ansible"
  location            = var.resource_group_location3
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNicConfiguration-ansible"
    subnet_id                     = azurerm_subnet.myterraformsubnet-ansible.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip-ansible.id
  }
}

# Create (and display) an SSH key
resource "azurerm_ssh_public_key" "ssh-ansible" {
  name                = "sshkey-ansible"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.resource_group_location3
  public_key          = data.vault_generic_secret.secret-vm.data.id_rsapub
}

#Create virtual machine centos awx
resource "azurerm_linux_virtual_machine" "ansible-vm" {
  name                  = "ansible-vm"
  location              = var.resource_group_location3
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.myterraformnic-ansible.id]
  size                  = "Standard_B1s"

  os_disk {
    name                 = "myOsDisk-ansible"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # source_image_reference {
  #   publisher = "OpenLogic"
  #   offer     = "CentOS"
  #   sku       = "8_5-gen2"
  #   version   = "latest"
  # }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }


  computer_name = "ansible-vm"
  #admin_username                  = var.admin_username
  #admin_password                  = var.admin_password
  admin_username                  = data.vault_generic_secret.secret-vm.data.admin_username
  admin_password                  = data.vault_generic_secret.secret-vm.data.admin_password
  disable_password_authentication = false

  admin_ssh_key {
    #username   = var.admin_username
    username   = data.vault_generic_secret.secret-vm.data.admin_username
    public_key = azurerm_ssh_public_key.ssh-ansible.public_key
  }
  depends_on = [
    azurerm_network_interface.myterraformnic-ansible
  ]

}