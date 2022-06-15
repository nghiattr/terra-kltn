provider "azurerm" {
  features {}
}


provider "vault" {
  address = "http://20.239.80.208:8200/"
  token   = var.tokenvar
}



