terraform {
  required_providers {
    aviatrix = {
      source = "aviatrixsystems/aviatrix"
    }
  }
  cloud {
    organization = "ananableu"
    workspaces {
      name = "aviatrix-shared-tgw"
    }
  }
}

provider "aviatrix" {
  controller_ip = var.controller_ip
  username      = "admin"
  password      = var.admin_password
}

provider "aws" {
  access_key = var.aws_access_key
  region     = var.aws_r1_location
  secret_key = var.aws_secret_key
}

resource "aviatrix_aws_tgw" "aws_tgw_fra" {
  account_name       = local.accounts.aws_account
  aws_side_as_number = 64500
  region             = var.aws_r1_location
  tgw_name           = "aws-${var.aws_r1_location_short}-tgw"
}
