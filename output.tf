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

# output "name-awx" {
#   value = azurerm_linux_virtual_machine.centos-vm.name

# }

# output "ippub-awx" {
#   value = azurerm_linux_virtual_machine.centos-vm.public_ip_address
# }

# output "name-arc" {
#   value = azurerm_container_registry.acrk8s.name

# }

# output "name-aks" {
#   value = azurerm_kubernetes_cluster.k8s-cluster.name
# }