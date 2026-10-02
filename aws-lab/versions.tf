terraform {
  required_providers {
    # aviatrix = {
    #   source = "aviatrixsystems/aviatrix"
    # }
    aws = {
      source = "hashicorp/aws"
    }
  }
  cloud {
    organization = "ananableu"
    workspaces {
      name = "aviatrix-aws-lab"
    }
  }
}
