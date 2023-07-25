resource "azurerm_resource_group" "azr-transit-r1-0-rg" {
  location = var.azure_r1_location
  name     = "azr-transit-${var.azure_r1_location_short}-0-rg"
}

resource "azurerm_resource_group" "azr-transit-r2-0-rg" {
  location = var.azure_r2_location
  name     = "azr-transit-${var.azure_r2_location_short}-0-rg"
}

data "dns_a_record_set" "controller_ip" {
  host = var.controller_fqdn
}
