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

module "aws_r1_spoke" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.6.3"

  cloud        = "AWS"
  name         = "aws-${var.aws_r1_location_short}-spoke"
  cidr         = "10.120.2.0/24"
  region       = var.aws_r1_location
  account      = var.aws_account
  transit_gw   = module.aws_transit_r1.transit_gateway.gw_name
  attached     = true
  ha_gw        = false
  single_az_ha = false
}
