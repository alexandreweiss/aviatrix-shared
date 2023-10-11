module "azure_transit_we" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.5.1"

  cloud                         = "azure"
  region                        = var.azure_r1_location
  cidr                          = "10.10.0.0/23"
  account                       = var.azure_account
  enable_transit_firenet        = true
  name                          = "azr-${var.azure_r1_location_short}-transit"
  local_as_number               = 65007
  enable_advertise_transit_cidr = false
  single_az_ha                  = false
  resource_group                = azurerm_resource_group.azr-transit-r1-0-rg.name
  bgp_lan_interfaces_count      = 3
  enable_bgp_over_lan           = true
  instance_size                 = "Standard_D4_v2"
}

output "transit_we" {
  value     = module.azure_transit_we
  sensitive = true
}

output "transit_we_gw_name" {
  value = module.azure_transit_we.transit_gateway.gw_name
}

output "transit_we_rg" {
  value = azurerm_resource_group.azr-transit-r1-0-rg.name
}
