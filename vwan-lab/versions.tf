terraform {
  required_providers {
    aviatrix = {
      source = "aviatrixsystems/aviatrix"
    }
  }
  cloud {
    organization = "ananableu"
    workspaces {
      name = "aviatrix-shared-vwan-lab"
    }
  }
}

provider "aviatrix" {
  controller_ip = data.dns_a_record_set.controller_ip.addrs[0]
  username      = "admin"
  password      = var.admin_password
}

provider "azurerm" {
  features {

  }
}

# provider "aws" {
# }
