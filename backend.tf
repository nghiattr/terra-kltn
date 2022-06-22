terraform {
  backend "azurerm" {
    resource_group_name  = "tf-backend"
    storage_account_name = "nghiathangtfbackend"
    container_name       = "container-tfback"
    key                  = "nghiatfstage"
  }
}