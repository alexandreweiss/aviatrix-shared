# //To be disabled when Edge is deployed on same public IP
# resource "aviatrix_transit_external_device_conn" "ferme" {
#   vpc_id                   = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.vpc_id
#   custom_algorithms        = true
#   connection_name          = "Ferme62"
#   connection_type          = "bgp"
#   tunnel_protocol          = "IPSEC"
#   bgp_local_as_num         = "65007"
#   bgp_remote_as_num        = "65510"
#   remote_gateway_ip        = data.dns_a_record_set.ferme.addrs[0]
#   local_tunnel_cidr        = "169.254.100.2/30,169.254.100.6/30"
#   remote_tunnel_cidr       = "169.254.100.1/30,169.254.100.5/30"
#   enable_edge_segmentation = false
#   pre_shared_key           = var.ferme_psk
#   phase_1_authentication   = "SHA-1"
#   phase_1_dh_groups        = "2"
#   phase_1_encryption       = "AES-256-CBC"
#   phase_2_authentication   = "HMAC-SHA-1"
#   phase_2_dh_groups        = "5"
#   phase_2_encryption       = "AES-256-CBC"
#   enable_ikev2             = true
#   gw_name                  = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.gw_name
#   phase1_remote_identifier = ["90.45.76.36"]
#   // Use in conjunction with Active / Standby on transit to do traffic on a single tunnel
#   //switch_to_ha_standby_gateway = true
# }

data "tfe_outputs" "spoke_app2" {
  organization = "ananableu"
  workspace    = "aviatrix-shared-spoke"
}

resource "aviatrix_site2cloud" "ferme" {
  vpc_id                     = data.tfe_outputs.spoke_app2.values.spoke_app2.spoke_gateway.vpc_id
  primary_cloud_gateway_name = data.tfe_outputs.spoke_app2.values.spoke_app2.spoke_gateway.gw_name
  connection_name            = "Ferme62-mapped"
  connection_type            = "mapped"
  tunnel_type                = "route"
  remote_gateway_ip          = data.dns_a_record_set.ferme.addrs[0]
  remote_gateway_type        = "generic"
  remote_subnet_cidr         = "192.168.16.0/24"
  remote_subnet_virtual      = "192.168.61.0/24"
  local_subnet_cidr          = "192.168.16.0/24"
  local_subnet_virtual       = "192.168.62.0/24"
  pre_shared_key             = var.ferme_psk
  phase1_remote_identifier   = ["90.45.76.36"]
  phase_1_authentication     = "SHA-1"
  phase_1_dh_groups          = "2"
  phase_1_encryption         = "AES-256-CBC"
  phase_2_authentication     = "HMAC-SHA-1"
  phase_2_dh_groups          = "5"
  phase_2_encryption         = "AES-256-CBC"
  enable_ikev2               = true
  custom_algorithms          = true

}

# resource "aviatrix_segmentation_network_domain_association" "name" {
#     attachment_name = aviatrix_transit_external_device_conn.ferme.connection_name
#     network_domain_name = aviatrix_segmentation_network_domain.branch_nd.domain_name
#     transit_gateway_name = module.azure_transit_we.transit_gateway.gw_name
# }

