provider "aviatrix" {
  //controller_ip = var.controller_ip
  controller_ip = "192.168.10.4"
  username = "admin"
  password = var.admin_password
}

provider "azurerm" {
  features {
    
  }
}