# IPsec IKEv2 + BGP to Cato (two remote peers, HA transit)
resource "aviatrix_transit_external_device_conn" "cato" {
  vpc_id            = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.vpc_id
  gw_name           = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.gw_name
  connection_name   = "Cato"
  connection_type   = "bgp"
  tunnel_protocol   = "IPSEC"
  enable_ikev2      = true
  bgp_local_as_num  = "65007"
  bgp_remote_as_num = "65111"

  # Primary tunnel (transit primary gw)
  remote_gateway_ip  = "113.30.136.81"
  local_tunnel_cidr  = "192.168.20.1/30,192.168.20.5/30"
  remote_tunnel_cidr = "192.168.20.2/30,192.168.20.6/30"

  # Backup tunnel (transit HA gw)
  ha_enabled                = true
  backup_remote_gateway_ip  = "113.30.136.22"
  backup_bgp_remote_as_num  = "65111"
  backup_local_tunnel_cidr  = "192.168.20.9/30,192.168.20.13/30"
  backup_remote_tunnel_cidr = "192.168.20.10/30,192.168.20.14/30"

  # PSKs are managed outside Terraform (never in git or workspace variables).
  # Changing them would force replacement of the connection and drop the tunnels.
  lifecycle {
    ignore_changes = [pre_shared_key, backup_pre_shared_key]
  }
}
