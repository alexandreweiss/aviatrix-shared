# NEO 1 WAN / 1012VC
resource "aviatrix_edge_platform_device_onboarding" "edge-1012-ferme" {

  account_name              = local.accounts.csp_account
  device_name               = "edge-1012-ferme"
  serial_number             = "GSAB295268"
  hardware_model            = "ADV-1012-1-WAN"
  config_file_download_path = "./"
  download_config_file      = false

  network {
    interface_name = "eth2"
    enable_dhcp    = true
    # ipv4_cidr      = "192.168.18.2/24"
    # gateway_ip     = "192.168.18.1"
    # dns_server_ips = ["1.1.1.1"]


  }
}
