terraform {
  required_providers {
    aviatrix = {
      source = "aviatrixsystems/aviatrix"
    }
  }
  cloud {
    organization = "ananableu"
    workspaces {
      name = "aviatrix-shared-staging-p2s"
    }
  }
}

provider "aviatrix" {
  controller_ip           = "134.33.141.31"
  username                = "admin"
  password                = var.admin_password
  skip_version_validation = true
}
