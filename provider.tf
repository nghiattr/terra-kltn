provider "azurerm" {
  features {}
}


provider "vault" {
  address = "http://20.205.97.64:8200/"
  token   = var.tokenvar
}



