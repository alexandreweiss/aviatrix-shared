# Resource group creation
resource "random_integer" "random" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "mp_lab_r1" {
  location = var.azure_r1_location
  name     = "er-lab-${var.azure_r1_location_short}-${random_integer.random.result}"
}

# Retrieve Megaport Equinix PA2/PA3 location details
data "megaport_location" "mp_location" {
  name = "Equinix NY9"
}

# data "megaport_location" "er_location" {
#   name = "Equinix NY9"
# }

# data "megaport_partner" "er_paris" {
#   connect_type = "AZURE"
#   product_name = "Paris Primary"
#   speed        = 10000
# }

# create MCR based on the location details
resource "megaport_mcr" "mcr" {
  location_id          = data.megaport_location.mp_location.id
  product_name         = "aweiss-${random_integer.random.result}-mcr-${var.mp_location_short}"
  port_speed           = 1000
  asn                  = var.mp_mcr_asn
  contract_term_months = 12
}

# Create Megaport Azure VXC
resource "megaport_vxc" "er_vxc" {
  product_name         = "aweiss-${random_integer.random.result}-vxc-${var.mp_location_short}"
  rate_limit           = 50
  contract_term_months = 1

  a_end = {
    requested_product_uid = megaport_mcr.mcr.product_uid
    # ordered_vlan          = var.private_peering_vlanid
  }

  b_end = {
  }

  b_end_partner_config = {
    partner = "azure"
    azure_config = {
      port_choice = "primary"
      service_key = module.azr_er_circuit_1.service_key
      peers = [
        {
          peer_asn         = var.mp_mcr_asn
          primary_subnet   = "169.254.247.0/30"
          secondary_subnet = "169.254.247.4/30"
          type             = "private"
          vlan             = var.private_peering_vlanid
      }]
    }
  }
  depends_on = [module.azr_er_circuit_1]
}

## Azure Express Route Circuit creation (Azure Side)
module "azr_er_circuit_1" {
  source = "github.com/alexandreweiss/misc-tf-modules/er-circuit"

  circuit_name        = "er-${random_integer.random.result}-mp-${var.er_peering_location_short}"
  peering_location    = var.er_peering_location
  location            = azurerm_resource_group.mp_lab_r1.location
  resource_group_name = azurerm_resource_group.mp_lab_r1.name
}
