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
  # ACE147 subscription_id = "546d1d9f-287b-476d-b8e7-7e5c34831379"
  subscription_id = "cc67e95e-9baa-4ef4-bfac-a33a19ef2232"
}

provider "aviatrix" {
  username                = var.admin_username
  password                = var.admin_password
  controller_ip           = data.dns_a_record_set.controller_ip.addrs[0]
  skip_version_validation = true
}
