terraform {
  required_providers {
    aviatrix = {
      source = "aviatrixsystems/aviatrix"
    }
  }
}

data "azurerm_subscription" "current" {}

provider "azurerm" {
  features {

  }
  subscription_id = "ff71e72e-9667-4783-a17d-e30f52285d3e"
}

provider "aviatrix" {
  username                = var.admin_username
  password                = var.admin_password
  controller_ip           = data.dns_a_record_set.controller_ip.addrs[0]
  skip_version_validation = true
}
