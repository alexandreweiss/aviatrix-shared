provider "azurerm" {
  features {

  }
  resource_provider_registrations = "none"
}

provider "aviatrix" {
  controller_ip           = data.dns_a_record_set.controller_ip.addrs[0]
  username                = var.admin_username
  password                = var.admin_password
  skip_version_validation = true
}
