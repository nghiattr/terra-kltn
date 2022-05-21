provider "azurerm" {
  features {}
}


provider "vault" {
  address = "http://20.58.189.53:8200/"
  token   = "${var.tokenvar}"
}



