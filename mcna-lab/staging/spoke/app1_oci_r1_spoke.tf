module "oci_r1_spoke_app1" {
  source = "terraform-aviatrix-modules/mc-spoke/aviatrix"

  cloud    = "OCI"
  name     = "oci-${var.oci_r1_location_short}-spoke-${var.application_1}-${var.customer_name}"
  cidr     = "10.54.0.0/24"
  region   = var.oci_r1_location
  account  = var.oci_account
  attached = false
  # transit_gw     = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.gw_name
  instance_size  = "VM.E4.Flex.4.16"
  ha_gw          = false
  single_ip_snat = true
}
