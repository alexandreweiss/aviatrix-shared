module "azure_transit_we" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.4.0"

  cloud                         = "azure"
  region                        = var.azure_r1_location
  cidr                          = "10.10.0.0/23"
  account                       = local.accounts.azure_account
  enable_transit_firenet        = true
  gw_name                       = "azr-${var.azure_r1_location_short}-transit"
  local_as_number               = 65007
  enable_segmentation           = true
  enable_advertise_transit_cidr = true
  single_az_ha                  = false
  resource_group                = azurerm_resource_group.azr-transit-r1-0-rg.name
  //instance_size = "Standard_B2ms"

}

module "azure_transit_ne_vwan" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.4.0"

  cloud                    = "azure"
  region                   = var.azure_r2_location
  cidr                     = "10.70.0.0/23"
  account                  = local.accounts.azure_account
  enable_transit_firenet   = true
  gw_name                  = "azr-${var.azure_r2_location_short}-vwan-transit"
  local_as_number          = 65010
  enable_bgp_over_lan      = true
  bgp_lan_interfaces_count = 1
  resource_group           = azurerm_resource_group.azr-transit-ne-0-rg.name

  //instance_size = "Standard_B2ms"

}

# module "azure_transit_ne" {
#   source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
#   version = "2.4.0"

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
#   version = "2.4.0"

#   cloud           = "GCP"
#   region          = var.gcp_r1_location
#   cidr            = "10.30.0.0/23"
#   account         = local.accounts.gcp_account
#   gw_name         = "gcp-${var.azure_r1_location_short}-transit"
#   local_as_number = 65009
#   single_az_ha    = false
# }

