terraform {
  backend "azurerm" {
    resource_group_name  = "tf-backend"
    storage_account_name = "nghiatfbackend"
    container_name       = "container-tfback"
    key                  = "nghiatfstage"
  }
}