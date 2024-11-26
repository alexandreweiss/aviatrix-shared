module "oci_transit_r1_0" {
  source = "terraform-aviatrix-modules/mc-transit/aviatrix"
  # version = "2.5.3"

  cloud           = "OCI"
  region          = var.oci_r1_location
  cidr            = "10.28.0.0/23"
  account         = var.oci_account
  local_as_number = 65002
  single_az_ha    = false
  ha_gw           = true
  insane_mode     = true
  name            = "oci-${var.oci_r1_location_short}-transit-${var.customer_name}"
  # bgp_lan_interfaces_count      = 1
  enable_bgp_over_lan = false
}
