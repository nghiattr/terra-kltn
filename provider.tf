provider "azurerm" {
  features {}
}


provider "vault" {
  address = "http://20.187.122.92:8200/"
  token   = var.tokenvar
}



