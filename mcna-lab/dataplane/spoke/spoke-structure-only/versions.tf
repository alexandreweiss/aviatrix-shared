terraform {
  required_providers {
    aviatrix = {
      source = "aviatrixsystems/aviatrix"
    }
    aws = {
      source = "hashicorp/aws"
    }
    ssh = {
      source = "loafoe/ssh"
    }
  }
  cloud {
    organization = "ananableu"
    workspaces {
      name = "aviatrix-shared-spoke-structure-only"
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

provider "aws" {
}
