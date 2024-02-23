resource "aviatrix_edge_vm_selfmanaged" "edge0" {
  gw_name                = "${var.remote_location_type}-${var.remote_location}-edge"
  site_id                = var.remote_location
  ztp_file_download_path = "/tmp"
  ztp_file_type          = "iso"
  local_as_number        = var.edge_local_as_number
  latitude               = var.remote_location_lat
  longitude              = var.remote_location_lon
  interfaces {
    name          = "eth0"
    type          = "WAN"
    ip_address    = "192.168.70.10/24"
    gateway_ip    = "192.168.70.1"
    wan_public_ip = "81.49.43.155"
    # wan_public_ip = "77.159.218.94"
    # wan_public_ip = "92.184.106.15"
  }
  interfaces {
    name       = "eth1"
    type       = "LAN"
    ip_address = "${var.edge_lan_bgp_ip}/24"
  }
  interfaces {
    name          = "eth2"
    type          = "MANAGEMENT"
    enable_dhcp   = true
    wan_public_ip = "81.49.43.155"
    # wan_public_ip = "77.159.218.94"
    # wan_public_ip = "92.184.106.15"
  }
}

resource "aviatrix_edge_spoke_transit_attachment" "edge0-azr-r1-transit" {
  spoke_gw_name               = aviatrix_edge_vm_selfmanaged.edge0.gw_name
  transit_gw_name             = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.gw_name
  enable_over_private_network = false
}

# Create an Edge as a Spoke External Device Connection
resource "aviatrix_edge_spoke_external_device_conn" "bgpolan" {
  site_id           = var.remote_location
  connection_name   = "${var.remote_location_type}-${var.remote_location}-edge-to-lan"
  gw_name           = aviatrix_edge_vm_selfmanaged.edge0.gw_name
  bgp_local_as_num  = aviatrix_edge_vm_selfmanaged.edge0.local_as_number
  bgp_remote_as_num = "65171"
  local_lan_ip      = var.edge_lan_bgp_ip
  remote_lan_ip     = var.remote_lan_bgp_ip
}
