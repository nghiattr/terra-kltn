provider "azurerm" {
  features {}
}


provider "vault" {
  address = "http://104.208.65.251:8200/"
  token   = var.tokenvar
}



