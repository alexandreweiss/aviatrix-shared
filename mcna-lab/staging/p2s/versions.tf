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
  controller_ip           = "4.211.181.32"
  username                = "admin"
  password                = var.admin_password
  skip_version_validation = true
}
