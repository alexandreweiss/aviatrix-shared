module "gcp_transit_we" {
  source = "terraform-aviatrix-modules/mc-transit/aviatrix"
  # version = "2.5.0"

  cloud                  = "GCP"
  region                 = var.gcp_r1_location
  cidr                   = "10.30.0.0/23"
  account                = var.gcp_account
  gw_name                = "gcp-${var.azure_r1_location_short}-transit-${var.customer_name}"
  local_as_number        = 65009
  single_az_ha           = false
  enable_transit_firenet = true
  lan_cidr               = "10.30.2.0/24"
  ha_gw                  = false
}


# module "aws_transit_fra" {
#   source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
#   version = "2.5.0"

#   cloud                  = "aws"
#   region                 = var.aws_r1_location
#   cidr                   = "10.50.0.0/23"
#   account                = var.aws_account
#   enable_transit_firenet = true
#   gw_name                = "aws-${var.aws_r1_location_short}-transit-${var.customer_name}"
#   local_as_number        = 65011
#   enable_segmentation    = false
#   // this is to enable connection to AWS TGW
#   hybrid_connection = true
# }

output "transit_gcp_r1" {
  value     = module.gcp_transit_we
  sensitive = true
}

output "transit_gcp_r1_gw_name" {
  value = module.gcp_transit_we.transit_gateway.gw_name
}
