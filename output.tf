output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "name-jenkins" {
  value = azurerm_linux_virtual_machine.jenkins-sv.name

}

output "ippub-jenkins" {
  value = azurerm_linux_virtual_machine.jenkins-sv.public_ip_address
}

output "name-gitlab" {
  value = azurerm_linux_virtual_machine.gitlab-sv.name

}

output "ippub-gitlab" {
  value = azurerm_linux_virtual_machine.gitlab-sv.public_ip_address
}

output "name-sonar" {
  value = azurerm_linux_virtual_machine.sonar-sv.name

}

output "ippub-sonar" {
  value = azurerm_linux_virtual_machine.sonar-sv.public_ip_address
}

output "name-nexus" {
  value = azurerm_linux_virtual_machine.nexus-vm.name

}

output "ippub-nexus" {
  value = azurerm_linux_virtual_machine.nexus-vm.public_ip_address
}

output "name-slave" {
  value = azurerm_linux_virtual_machine.jenkins-slave.name

}

output "ippub-slave" {
  value = azurerm_linux_virtual_machine.jenkins-slave.public_ip_address
}


# output "name-aks" {
#   value = azurerm_kubernetes_cluster.k8s-cluster.name
# }