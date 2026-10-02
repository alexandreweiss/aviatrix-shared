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
      name = "aviatrix-shared-staging-spoke"
    }
  }
}

provider "aviatrix" {
  controller_ip           = "134.33.141.31"
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
