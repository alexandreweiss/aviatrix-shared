terraform {
  required_providers {
    aviatrix = {
      source = "aviatrixsystems/aviatrix"
    }
    cato = {
      source  = "catonetworks/cato"
      version = "~> 1.4"
    }
    dns = {
      source = "hashicorp/dns"
    }
  }
  cloud {
    organization = "ananableu"
    workspaces {
      name = "aviatrix-shared-cato"
    }
  }
}

provider "aviatrix" {
  controller_ip           = data.dns_a_record_set.controller_ip.addrs[0]
  username                = "admin"
  password                = var.admin_password
  skip_version_validation = true
}

provider "cato" {
  baseurl    = "https://api.catonetworks.com/api/v1/graphql2"
  token      = var.cato_api_key
  account_id = var.cato_account_id
}
