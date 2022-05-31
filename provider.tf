provider "azurerm" {
  features {}
}


provider "vault" {
  address = "http://20.187.75.182:8200/"
  token   = var.tokenvar
}



