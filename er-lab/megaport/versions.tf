terraform {
  cloud {
    organization = "ananableu"
    workspaces {
      name = "aviatrix-shared-megaport-lab"
    }
  }
  required_providers {
    megaport = {
      source = "megaport/megaport"
    }
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}
