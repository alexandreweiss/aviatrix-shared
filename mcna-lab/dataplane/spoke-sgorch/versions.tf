terraform {
  required_providers {
    aviatrix = {
      source = "aviatrixsystems/aviatrix"
    }
    guacamole = {
      source = "techBeck03/guacamole"
    }
    ssh = {
      source = "loafoe/ssh"
    }
  }
  cloud {
    organization = "ananableu"
    workspaces {
      name = "aviatrix-shared-spoke-sgorch"
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

provider "aws" {
}
