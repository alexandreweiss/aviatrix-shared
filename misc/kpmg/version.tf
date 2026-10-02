terraform {
  required_providers {
    aviatrix = {
      source = "aviatrixsystems/aviatrix"
    }
  }
}

provider "aviatrix" {
  controller_ip           = var.controller_fqdn
  username                = "admin"
  password                = var.admin_password
  skip_version_validation = true
}
