provider "azurerm" {
  features {

  }
}

provider "megaport" {
  access_key            = var.access_key
  secret_key            = var.secret_key
  accept_purchase_terms = true
  environment           = "production"
}
