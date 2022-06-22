provider "azurerm" {
  features {}
}


provider "vault" {
  address = "http://104.208.111.106:8200/"
  token   = var.tokenvar
}



