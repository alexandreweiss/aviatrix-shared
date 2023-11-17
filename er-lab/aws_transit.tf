module "aws_transit_r1" {
  source = "terraform-aviatrix-modules/mc-transit/aviatrix"
  //version = "2.5.1"

  cloud                         = "AWS"
  region                        = var.aws_r1_location
  cidr                          = "10.120.0.0/23"
  account                       = var.aws_account
  name                          = "aws-${var.aws_r1_location_short}-transit"
  local_as_number               = 65015
  insane_mode                   = true
  enable_advertise_transit_cidr = true
}

