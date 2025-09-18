// APP1 SPOKE in R1

// Replace app1 by app2 as need be
// Replace application_1 by application_2 as need be
// Replace CIDR block as need be 10.10.2 for app1, 10.11.2 for app2 ...

module "gcp_r1_spoke_app1" {
  source = "terraform-aviatrix-modules/mc-spoke/aviatrix"

  cloud   = "GCP"
  name    = "gcp-${var.gcp_r1_location_short}-spoke-${var.application_1}-${var.customer_name}"
  region  = var.gcp_r1_location
  account = var.gcp_account
  # transit_gw = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.gw_name
  # transit_gw = "azr-we-ars-transit"
  attached = false
  # Must be enabled for HPE
  ha_gw = false
  //network_domain = aviatrix_segmentation_network_domain.dev_nd.domain_name
  single_ip_snat = true
  single_az_ha   = false
  #local_as_number = 65012
  insane_mode = false
  #bgp_lan_interfaces_count = 1
  #enable_bgp_over_lan      = true
}

output "spoke_app1" {
  value     = module.gcp_r1_spoke_app1
  sensitive = true
}
