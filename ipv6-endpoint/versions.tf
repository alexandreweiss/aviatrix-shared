terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.0.0"
    }
  }
  cloud {
    organization = "ananableu"
    workspaces {
      name = "aviatrix-shared-ipv6-endpoint"
    }
  }
}

provider "azurerm" {
  features {

  }
}
