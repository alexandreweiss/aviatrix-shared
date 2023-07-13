provider "azurerm" {
  features {}
}

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
  cloud {
    organization = "ananableu"
    workspaces {
      name = "aviatrix-shared-0-dns"
    }
  }
}

resource "azurerm_dns_a_record" "ctrl" {
  name                = "avx-ctrl-ne"
  resource_group_name = "core-rg"
  ttl                 = 3600
  zone_name           = "ananableu.fr"
  records             = ["4.210.87.221"]
}

resource "azurerm_dns_a_record" "cplt" {
  name                = "avx-cplt-ne"
  resource_group_name = "core-rg"
  ttl                 = 3600
  zone_name           = "ananableu.fr"
  records             = ["68.219.101.118"]
}

resource "azurerm_dns_cname_record" "controller" {
  name                = "controller"
  resource_group_name = "core-rg"
  ttl                 = 3600
  zone_name           = "ananableu.fr"
  record              = "avx-ctrl-ne.ananableu.fr"
}

resource "azurerm_dns_a_record" "controller-int" {
  name                = "controller-int"
  resource_group_name = "core-rg"
  ttl                 = 3600
  zone_name           = "ananableu.fr"
  records             = ["192.168.10.4"]
}

resource "azurerm_dns_a_record" "copilot-int" {
  name                = "copilot-int"
  resource_group_name = "core-rg"
  ttl                 = 3600
  zone_name           = "ananableu.fr"
  records             = ["192.168.10.5"]
}

resource "azurerm_dns_cname_record" "copilot" {
  name                = "copilot"
  resource_group_name = "core-rg"
  ttl                 = 3600
  zone_name           = "ananableu.fr"
  record              = "avx-cplt-ne.ananableu.fr"
}
