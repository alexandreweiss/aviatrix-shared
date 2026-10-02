terraform {
  cloud {
    organization = "ananableu"
    workspaces {
      name = "aviatrix-shared-azfw"
    }
  }
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}
