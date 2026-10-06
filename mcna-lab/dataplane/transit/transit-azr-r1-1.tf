resource "azurerm_resource_group" "azr-transit-r1-1-rg" {
  location = var.azure_r1_location
  name     = "azr-transit-${var.azure_r1_location_short}-1-${var.customer_name}-rg"
}

module "azure_transit_we_1" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "~> 10.1.0"

  cloud                         = "azure"
  region                        = var.azure_r1_location
  cidr                          = "10.11.0.0/23"
  account                       = var.azure_account
  enable_transit_firenet        = true
  name                          = "azr-${var.azure_r1_location_short}-transit-1-${var.customer_name}"
  local_as_number               = 65008
  enable_advertise_transit_cidr = false
  single_az_ha                  = false
  ha_gw                         = true
  enable_segmentation           = true
  resource_group                = azurerm_resource_group.azr-transit-r1-1-rg.name
  enable_bgp_over_lan           = false
  instance_size                 = "Standard_D8s_v5"
  insane_mode                   = false
  tags = {
    csp-environment : "tst",
    csp-department : "dept-530",
    shutdown : "stop",
    schedule : "08:00-11:00;mo,tu,we,th,fr;europe-paris"
    LegacyVMNVA : "true"
  }
}

output "transit_we_1" {
  value     = module.azure_transit_we_1
  sensitive = true
}

output "transit_we_1_gw_name" {
  value     = module.azure_transit_we_1.transit_gateway.gw_name
  sensitive = true
}

output "transit_we_1_rg" {
  value = azurerm_resource_group.azr-transit-r1-1-rg.name
}
