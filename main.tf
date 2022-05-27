


data "vault_generic_secret" "secret-vm" {
  path = "authen/secret-vm"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork" {
  name = "myVnet-assign2"
  #address_space       = ["10.0.0.0/16"]
  address_space       = ["172.16.0.0/12"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "myterraformsubnet" {
  name                 = "mySubnet-assign2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
  #address_prefixes     = ["10.0.1.0/24"]
  address_prefixes = ["172.17.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip" {
  name                = "myPublicIP-assign2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
  name                = "myNIC-assign2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNicConfiguration-assign2"
    subnet_id                     = azurerm_subnet.myterraformsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip.id
  }
}

#Sonar
# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip-sonar" {
  name                = "myPublicIP-sonar"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic-sonar" {
  name                = "myNIC-sonar"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNicConfiguration-sonar"
    subnet_id                     = azurerm_subnet.myterraformsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip-sonar.id
  }
}

#Slave
# Create public IPs
resource "azurerm_public_ip" "myterraformpublicip-slave" {
  name                = "myPublicIP-slave"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Create network interface
resource "azurerm_network_interface" "myterraformnic-slave" {
  name                = "myNIC-slave"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNicConfiguration-slave"
    subnet_id                     = azurerm_subnet.myterraformsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myterraformpublicip-slave.id
  }
}


# Create (and display) an SSH key
resource "azurerm_ssh_public_key" "example_ssh" {
  name                = "sshkey-linux"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  #public_key          = file("./id_rsa.pub")
  public_key = data.vault_generic_secret.secret-vm.data.id_rsapub
}

# Create virtual machine Linux for Jenkins-GitLab Server
resource "azurerm_linux_virtual_machine" "jenkins-sv" {
  name                  = "jenkins-sv"
  location              = var.resource_group_location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.myterraformnic.id]
  size                  = "Standard_B1s"
  #Standard_B4ms

  os_disk {
    name                 = "myOsDisk-jenkins-sv"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  computer_name  = "jenkins-sv"
  admin_username = data.vault_generic_secret.secret-vm.data.admin_username
  admin_password = data.vault_generic_secret.secret-vm.data.admin_password
  #admin_username                  = var.admin_username
  #admin_password                  = var.admin_password
  disable_password_authentication = false

  admin_ssh_key {
    #username   = var.admin_username
    username   = data.vault_generic_secret.secret-vm.data.admin_username
    public_key = azurerm_ssh_public_key.example_ssh.public_key
  }
}

resource "azurerm_linux_virtual_machine" "sonar-sv" {
  name                  = "sonar-sv"
  location              = var.resource_group_location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.myterraformnic-sonar.id]
  size                  = "Standard_B1s"
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
}

resource "azurerm_linux_virtual_machine" "jenkins-slave" {
  name                  = "jenkins-slave"
  location              = var.resource_group_location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.myterraformnic-slave.id]
  size                  = "Standard_F2s_v2"
  #Standard_B4ms

  os_disk {
    name                 = "myOsDisk-jenkins-slave"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  computer_name  = "jenkins-slave"
  admin_username = data.vault_generic_secret.secret-vm.data.admin_username
  admin_password = data.vault_generic_secret.secret-vm.data.admin_password
  #admin_username                  = var.admin_username
  #admin_password                  = var.admin_password
  disable_password_authentication = false

  admin_ssh_key {
    #username   = var.admin_username
    username   = data.vault_generic_secret.secret-vm.data.admin_username
    public_key = azurerm_ssh_public_key.example_ssh.public_key
  }
}


/*-----------------------Create AKS--------------------------------------------*/

# Create virtual network
resource "azurerm_virtual_network" "myterraformnetwork-k8s" {
  name = "myVnet-K8s"
  #address_space       = ["10.0.0.0/16"]
  address_space       = ["177.16.0.0/12"]
  location            = var.resource_group_location2
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "akspodssubnet" {
  name                = "akspodssubnet"
  resource_group_name = azurerm_resource_group.rg.name
  #virtual_network_name        = azurerm_virtual_network.vnetaks.name   dif vnet
  #address_prefixes              = ["172.16.0.0/24"]
  virtual_network_name = azurerm_virtual_network.myterraformnetwork-k8s.name
  address_prefixes     = ["177.16.2.0/24"]

}

resource "azurerm_kubernetes_cluster" "k8s-cluster" {

  name                = "azure-aks"
  location            = var.resource_group_location2
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "k8s-cluster"
  node_resource_group = "K8S${azurerm_resource_group.rg.name}"
  kubernetes_version  = "1.21.9"



  default_node_pool {

    name                = "default"
    node_count          = 1
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 2
    #vm_size             = "Standard_B1s"
    vm_size        = "Standard_F2s_v2"
    vnet_subnet_id = azurerm_subnet.akspodssubnet.id

  }

  linux_profile {
    #admin_username = var.admin_username
    admin_username = data.vault_generic_secret.secret-vm.data.admin_username
    #admin_password = data.vault_generic_secret.secret-vm.data.admin_password
    ssh_key { key_data = azurerm_ssh_public_key.example_ssh.public_key }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }

}

#add the role to the identity the kubernetes cluster was assigned

# resource "azurerm_role_assignment" "role-aks" {

#   principal_id                     = azurerm_kubernetes_cluster.k8s-cluster.kubelet_identity[0].object_id
#   role_definition_name             = "AcrPull"
#   scope                            = azurerm_container_registry.acrk8s.id
#   skip_service_principal_aad_check = true

# }




#Ansible

resource "null_resource" "install_and_run_ansible2" {
  depends_on = [azurerm_linux_virtual_machine.centos-vm]
  connection {
    type = "ssh"
    #user = var.admin_username
    #password = var.admin_password
    user = data.vault_generic_secret.secret-vm.data.admin_username
    #password = data.vault_generic_secret.secret-vm.data.admin_password
    private_key = data.vault_generic_secret.secret-vm.data.id_rsa
    host        = azurerm_linux_virtual_machine.centos-vm.public_ip_address
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir /home/ac",
      "sudo chmod 777 /home/ac"
    ]
  }
  provisioner "file" {
    source      = "./install-awx.sh"
    destination = "/home/ac/install-awx.sh"
  }
  provisioner "file" {
    source      = "./ansible-assign3/"
    destination = "/home/ac/"
  }



  provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /home/ac/install-awx.sh",
      "sudo /home/ac/install-awx.sh",
      "sudo chmod 777 /etc/ansible/ansible.cfg",
      "echo $'[defaults] \nhost_key_checking = false' > /etc/ansible/ansible.cfg",
      "echo 'server1 ansible_host=${azurerm_linux_virtual_machine.jenkins-sv.public_ip_address} ansible_user=labadmin ansible_password=Password1234! ansible_python_interpreter=/usr/bin/python3' > /home/ac/inventory ",
      "echo 'server2 ansible_host=${azurerm_linux_virtual_machine.gitlab-sv.public_ip_address} ansible_user=labadmin ansible_password=Password1234! ansible_python_interpreter=/usr/bin/python3' > /home/ac/inventory2 ",
      "echo 'server3 ansible_host=${azurerm_linux_virtual_machine.nexus-vm.public_ip_address} ansible_user=labadmin ansible_password=Password1234! ansible_python_interpreter=/usr/bin/python3' > /home/ac/inventory3 ",
      "echo 'server4 ansible_host=${azurerm_linux_virtual_machine.sonar-sv.public_ip_address} ansible_user=labadmin ansible_password=Password1234! ansible_python_interpreter=/usr/bin/python3' > /home/ac/inventory4 ",
      "echo 'server5 ansible_host=${azurerm_linux_virtual_machine.jenkins-slave.public_ip_address} ansible_user=labadmin ansible_password=Password1234! ansible_python_interpreter=/usr/bin/python3' > /home/ac/inventory5 ",


      "ansible-playbook /home/ac/playbook.yaml -i /home/ac/inventory -u labadmin ",
      "ansible-playbook /home/ac/playbook.yaml -i /home/ac/inventory2 -u labadmin ",
      "ansible-playbook /home/ac/playbook.yaml -i /home/ac/inventory3 -u labadmin ",
      "ansible-playbook /home/ac/playbook.yaml -i /home/ac/inventory4 -u labadmin ",
      "ansible-playbook /home/ac/playbook.yaml -i /home/ac/inventory5 -u labadmin ",

    ]
  }


  # provisioner "local-exec" {
  #   command     = "psql 'host=postgresql-server-nghiattr.postgres.database.azure.com port=5432 dbname=postgres user=labadmin password=H@Sh1CoR3! sslmode=require' -f postgres.sql"
  #   interpreter = ["bash", "-c"]
  # }
}

resource "null_resource" "install_and_run_nexus" {
  depends_on = [null_resource.install_and_run_ansible2]
  connection {
    type = "ssh"
    #user = var.admin_username
    user = data.vault_generic_secret.secret-vm.data.admin_username
    #password = var.admin_password
    private_key = data.vault_generic_secret.secret-vm.data.id_rsa
    host        = azurerm_linux_virtual_machine.nexus-vm.public_ip_address
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 777 /opt/"
    ]
  }
  provisioner "file" {
    source      = "./install-nexus.sh"
    destination = "/opt/install-nexus.sh"
  }


  provisioner "remote-exec" {
    inline = [
      "sudo chmod 777 /opt/install-nexus.sh",
      "sudo bash /opt/install-nexus.sh",
    ]
  }

}


# resource "null_resource" "install_prometheus_grafana" {
#   depends_on = [azurerm_kubernetes_cluster.k8.k8s-cluster]
#   connection {
#     type = "ssh"
#     user = data.vault_generic_secret.secret-vm.data.admin_username
#     private_key = data.vault_generic_secret.secret-vm.data.id_rsa
#     host        = azurerm_linux_virtual_machine.centos-vm.public_ip_address
#   }

#   provisioner "remote-exec" {
#     inline = []
#   }



# }