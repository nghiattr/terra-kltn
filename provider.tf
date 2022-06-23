provider "azurerm" {
  features {}
}


provider "vault" {
  address = "http://20.239.167.145:8200/"
  token   = var.tokenvar
}



