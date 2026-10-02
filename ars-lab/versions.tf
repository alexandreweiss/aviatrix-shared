terraform {
  cloud {
    organization = "ananableu"
    workspaces {
      name = "aviatrix-shared-ars-lab"
    }
  }
  required_providers {
    aviatrix = {
      source = "aviatrixsystems/aviatrix"
    }
  }
}

provider "aviatrix" {
  controller_ip           = data.dns_a_record_set.controller_ip.addrs[0]
  username                = "admin"
  password                = var.admin_password
  skip_version_validation = true
}

provider "azurerm" {
  features {

  }
}
