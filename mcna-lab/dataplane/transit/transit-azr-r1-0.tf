data "dns_a_record_set" "controller_ip" {
  host = var.controller_fqdn
}

module "azure_transit_we" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.5.0"

  cloud                         = "azure"
  region                        = var.azure_r1_location
  cidr                          = "10.10.0.0/23"
  account                       = local.accounts.azure_account
  enable_transit_firenet        = true
  name                          = "azr-${var.azure_r1_location_short}-transit"
  local_as_number               = 65007
  enable_advertise_transit_cidr = false
  single_az_ha                  = false
  resource_group                = azurerm_resource_group.azr-transit-r1-0-rg.name
  bgp_lan_interfaces_count      = 1
  enable_bgp_over_lan           = true
}

# resource "azurerm_resource_group" "azr-transit-r1-1-rg" {
#   location = var.azure_r1_location
#   name     = "azr-transit-${var.azure_r1_location_short}-1-rg"
# }

# module "azure_transit_we_egress" {
#   source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
#   version = "2.5.0"

#   cloud                         = "azure"
#   region                        = var.azure_r1_location
#   cidr                          = "10.40.0.0/23"
#   account                       = local.accounts.azure_account
#   enable_transit_firenet        = false
#   name                          = "azr-${var.azure_r1_location_short}-transit-egress"
#   local_as_number               = 65010
#   single_az_ha                  = false
#   ha_gw                         = false
#   resource_group                = azurerm_resource_group.azr-transit-r1-1-rg.name
#   enable_egress_transit_firenet = true
#   //instance_size = "Standard_B2ms"
# }

# module "azure_transit_ne" {
#   source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
#   version = "2.5.0"

#   cloud                  = "azure"
#   region                 = var.azure_r2_location
#   cidr                   = "10.20.0.0/23"
#   account                = local.accounts.azure_account
#   enable_transit_firenet = true
#   gw_name                = "azr-${var.azure_r2_location_short}-transit"
#   local_as_number        = 65008
#   enable_segmentation    = false
#   //single_az_ha           = false
#   //instance_size = "Standard_B2ms"
# }


# module "gcp_transit_we" {
#   source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
#   version = "2.5.0"

#   cloud           = "GCP"
#   region          = var.gcp_r1_location
#   cidr            = "10.30.0.0/23"
#   account         = local.accounts.gcp_account
#   gw_name         = "gcp-${var.azure_r1_location_short}-transit"
#   local_as_number = 65009
#   single_az_ha    = false
# }


# module "aws_transit_fra" {
#   source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
#   version = "2.5.0"

#   cloud                  = "aws"
#   region                 = var.aws_r1_location
#   cidr                   = "10.50.0.0/23"
#   account                = local.accounts.aws_account
#   enable_transit_firenet = true
#   gw_name                = "aws-${var.aws_r1_location_short}-transit"
#   local_as_number        = 65011
#   enable_segmentation    = false
#   // this is to enable connection to AWS TGW
#   hybrid_connection = true
# }
