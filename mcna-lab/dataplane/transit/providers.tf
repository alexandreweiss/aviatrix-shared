provider "aviatrix" {
  controller_ip = data.dns_a_record_set.controller_ip.addrs[0]
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
