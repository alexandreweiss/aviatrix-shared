# Create an Edge as a Spoke External Device Connection
resource "aviatrix_edge_spoke_external_device_conn" "bgpolan" {
  site_id           = "ferme"
  connection_name   = "edge-gw-ferme-lan-router"
  gw_name           = aviatrix_edge_platform.edge-gw-ferme.gw_name
  bgp_local_as_num  = aviatrix_edge_platform.edge-gw-ferme.local_as_number
  bgp_remote_as_num = "65181"
  local_lan_ip      = "192.168.180.1"
  remote_lan_ip     = "192.168.180.2"
}
