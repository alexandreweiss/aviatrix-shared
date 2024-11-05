terraform {
  required_providers {
    aviatrix = {
      source = "aviatrixsystems/aviatrix"
    }
  }
}

provider "azurerm" {
  features {

  }
  subscription_id = "546d1d9f-287b-476d-b8e7-7e5c34831379"
}

provider "aviatrix" {
  # controller_ip           = data.dns_a_record_set.controller_ip.addrs[0]
  controller_ip           = "107.20.161.165"
  username                = var.admin_username
  password                = var.admin_password
  skip_version_validation = true
}
