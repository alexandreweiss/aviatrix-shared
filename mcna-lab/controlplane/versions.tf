terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    azuread = {
      source = "hashicorp/azuread"
    }
  }
  cloud {
    organization = "ananableu"
    workspaces {
      name = "aviatrix-shared-control-plane-prd"
    }
  }
}
