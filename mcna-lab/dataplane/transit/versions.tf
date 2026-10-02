terraform {
  required_providers {
    aviatrix = {
      source = "aviatrixsystems/aviatrix"
      # version = "3.2.1"
    }
  }
  cloud {
    organization = "ananableu"
    workspaces {
      name = "aviatrix-shared"
    }
  }
}
