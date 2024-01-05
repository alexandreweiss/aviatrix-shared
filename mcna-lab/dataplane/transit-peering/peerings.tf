data "tfe_outputs" "dataplane" {
  organization = "ananableu"
  workspace    = "aviatrix-shared"
}

data "dns_a_record_set" "controller_ip" {
  host = var.controller_fqdn
}

module "transit_peering" {
  source  = "terraform-aviatrix-modules/mc-transit-peering/aviatrix"
  version = "1.0.8"

  transit_gateways = [
    nonsensitive(data.tfe_outputs.dataplane.values.transit_we_gw_name),
    nonsensitive(data.tfe_outputs.dataplane.values.aws_transit_r1_gw_name)
  ]
  //enable_insane_mode_encryption_over_internet = true
  //tunnel_count                                = 12
}
