provider "aviatrix" {
  controller_ip = var.controller_ip
  username      = "admin"
  password      = var.admin_password
}

provider "azurerm" {
  features {

  }
}

provider "azurerm" {
  features {
  }
  alias       = "china"
  environment = "china"
}
