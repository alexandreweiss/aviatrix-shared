# Resource group creation
resource "azurerm_resource_group" "mp_lab_r1" {
  location = var.azure_r1_location
  name     = "er-lab-${var.azure_r1_location_short}"
}

# Retrieve Megaport Equinix PA2/PA3 location details
data "megaport_location" "mp_location" {
  name = "Equinix PA2/3"
}

data "megaport_location" "er_location" {
  name = "Equinix PA2/3"
}

data "megaport_partner" "er_paris" {
  connect_type = "AZURE"
}

# create MCR based on the location details
resource "megaport_mcr" "mcr" {
  location_id          = data.megaport_location.mp_location.id
  product_name         = "mcr-ecx-pa2"
  port_speed           = 1000
  asn                  = 64001
  contract_term_months = 1
}

# Create Megaport Azure VXC
resource "megaport_vxc" "er_vxc" {
  product_name         = "er-paris"
  rate_limit           = 50
  contract_term_months = 1

  a_end = {
    requested_product_uid = megaport_mcr.mcr.product_uid
    ordered_vlan          = var.private_peering_vlanid
  }

  b_end = {
  }

  b_end_partner_config = {
    partner = "azure"
    azure_config = {
      port_choice = "primary"
      service_key = module.azr_er_circuit_1.service_key
    }
  }
}

## Azure Express Route Circuit creation (Azure Side)
module "azr_er_circuit_1" {
  source = "github.com/alexandreweiss/misc-tf-modules/er-circuit"

  circuit_name        = "er-pf-paris"
  peering_location    = "Paris"
  location            = azurerm_resource_group.mp_lab_r1.location
  resource_group_name = azurerm_resource_group.mp_lab_r1.name
}

## Azure Express Route Private peering creation
resource "azurerm_express_route_circuit_peering" "private" {
  express_route_circuit_name    = module.azr_er_circuit_1.circuit_name
  peering_type                  = "AzurePrivatePeering"
  resource_group_name           = azurerm_resource_group.mp_lab_r1.name
  vlan_id                       = var.private_peering_vlanid
  ipv4_enabled                  = true
  primary_peer_address_prefix   = "169.254.247.0/30"
  secondary_peer_address_prefix = "169.254.247.4/30"
  peer_asn                      = megaport_mcr.mcr.asn
}
