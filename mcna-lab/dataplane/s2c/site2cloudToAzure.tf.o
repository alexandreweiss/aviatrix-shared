//To be disabled when Edge is deployed on same public IP
resource "aviatrix_transit_external_device_conn" "azure_0" {
  vpc_id                    = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.vpc_id
  custom_algorithms         = true
  connection_name           = "Azure0"
  connection_type           = "bgp"
  tunnel_protocol           = "IPSEC"
  bgp_local_as_num          = "65007"
  bgp_remote_as_num         = "65515"
  remote_gateway_ip         = "20.82.54.148"
  local_tunnel_cidr         = "169.254.21.1/30,169.254.21.9/30"
  remote_tunnel_cidr        = "169.254.21.2/30,169.254.21.10/30"
  ha_enabled                = true
  backup_remote_gateway_ip  = "20.82.54.159"
  backup_bgp_remote_as_num  = "65515"
  backup_local_tunnel_cidr  = "169.254.21.5/30,169.254.21.13/30"
  backup_remote_tunnel_cidr = "169.254.21.6/30,169.254.21.14/30"
  pre_shared_key            = var.ferme_psk
  backup_pre_shared_key     = var.ferme_psk
  enable_edge_segmentation  = false
  phase_1_authentication    = "SHA-256"
  phase_1_dh_groups         = "2"
  phase_1_encryption        = "AES-256-CBC"
  phase_2_authentication    = "HMAC-SHA-256"
  phase_2_dh_groups         = "14"
  phase_2_encryption        = "AES-256-CBC"
  enable_ikev2              = true
  gw_name                   = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.gw_name

  //phase1_remote_identifier = ["90.45.76.36"]
  // Use in conjunction with Active / Standby on transit to do traffic on a single tunnel
  //switch_to_ha_standby_gateway = true
}

# resource "aviatrix_transit_external_device_conn" "azure_1" {
#   vpc_id                   = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.vpc_id
#   custom_algorithms        = true
#   connection_name          = "Azure1"
#   connection_type          = "bgp"
#   tunnel_protocol          = "IPSEC"
#   bgp_local_as_num         = "65007"
#   bgp_remote_as_num        = "65515"
#   remote_gateway_ip        = "20.82.54.159"
#   local_tunnel_cidr        = "169.254.21.10/30,169.254.21.14/30"
#   remote_tunnel_cidr       = "169.254.21.9/30,169.254.21.13/30"
#   enable_edge_segmentation = false
#   pre_shared_key           = var.ferme_psk
#   phase_1_authentication   = "SHA-256"
#   phase_1_dh_groups        = "2"
#   phase_1_encryption       = "AES-256-CBC"
#   phase_2_authentication   = "HMAC-SHA-256"
#   phase_2_dh_groups        = "14"
#   phase_2_encryption       = "AES-256-CBC"
#   enable_ikev2             = true
#   gw_name                  = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.gw_name
#   //phase1_remote_identifier = ["90.45.76.36"]
#   // Use in conjunction with Active / Standby on transit to do traffic on a single tunnel
#   //switch_to_ha_standby_gateway = true
# }
