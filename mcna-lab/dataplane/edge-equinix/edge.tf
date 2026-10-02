resource "aviatrix_edge_equinix" "edge" {
  gw_name                = "edgeecx"
  account_name           = "ecx"
  site_id                = "ferme-4"
  ztp_file_download_path = "./"

  interfaces {
    name          = "eth0"
    type          = "WAN"
    ip_address    = "10.89.0.20/24"
    gateway_ip    = "10.89.0.1"
    wan_public_ip = "81.49.209.68"
  }
  interfaces {
    name       = "eth1"
    type       = "LAN"
    ip_address = "10.10.10.20/24"
  }
  #   interfaces {
  #     name                    = "eth2"
  #     type                    = "MANAGEMENT"
  #     dns_server_ip           = "8.8.4.4"
  #     secondary_dns_server_ip = "1.0.0.1"
  #     enable_dhcp             = false
  #   }
}
