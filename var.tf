variable "resource_group_name" {
  default     = "devops-sys"
  description = "Location of the resource group."
}

variable "tokenvar" {}

variable "resource_group_location" {
  default     = "East Asia"
  description = "Location of the Jen-Jenslav-sonar."
}
variable "resource_group_location2" {
  default     = "Australia East"
  description = "Location of the K8s."
}
variable "resource_group_location3" {
  default     = "Japan East"
  description = "Location of the resource awx."
}
variable "resource_group_location4" {
  default     = "Australia Central"
  description = "Location of the gitlab."
}
variable "resource_group_location5" {
  default     = "Australia Southeast"
  description = "Location of the resource nexus."
}

variable "admin_username" {
  default     = "labadmin"
  description = "Admin username for all VMs"
}

variable "admin_password" {
  default     = "Password1234!"
  description = "Admin password for all VMs"
}