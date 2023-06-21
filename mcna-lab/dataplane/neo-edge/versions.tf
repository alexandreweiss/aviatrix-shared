terraform {
  required_providers {
    aviatrix = {
      source = "aviatrixsystems/aviatrix"
    }
  }
  cloud {
    organization = "ananableu"
    workspaces {
      name = "aviatrix-shared-eve-edge"
    }
  }
}

provider "aviatrix" {
  controller_ip = var.controller_ip
  username      = "admin"
  password      = var.admin_password
}

provider "azurerm" {
  features {

  }
}
