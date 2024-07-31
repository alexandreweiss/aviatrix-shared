module "aws_transit_r1" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.5.0"

  cloud                  = "aws"
  region                 = var.aws_r1_location
  cidr                   = "10.50.0.0/23"
  account                = var.aws_account
  enable_transit_firenet = true
  gw_name                = "aws-${var.aws_r1_location_short}-transit-${var.customer_name}"
  local_as_number        = 65011
  enable_segmentation    = true
  //insane_mode            = true
  name = "aws-${var.aws_r1_location_short}-transit-${var.customer_name}"
}

output "aws_transit_r1" {
  value     = module.aws_transit_r1
  sensitive = true
}

output "aws_transit_r1_gw_name" {
  value = module.aws_transit_r1.transit_gateway.gw_name
}
