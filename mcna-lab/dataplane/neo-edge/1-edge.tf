# Create an Edge NEO
resource "aviatrix_edge_platform" "edge-gw-ferme" {

  account_name                           = local.accounts.csp_account
  gw_name                                = "edge-gw-ferme"
  site_id                                = "ferme"
  gw_size                                = "small"
  local_as_number                        = 65180
  device_id                              = aviatrix_edge_platform_device_onboarding.edge-1012-ferme.device_id
  management_egress_ip_prefix_list       = ["${data.dns_a_record_set.ferme.addrs[0]}/32"]
  enable_management_over_private_network = false
  management_interface_names             = ["eth2"]
  lan_interface_names                    = ["eth4"]
  wan_interface_names                    = ["eth2"]



  interfaces {
    name          = "eth0"
    type          = "WAN"
    ip_address    = "192.168.18.10/24"
    gateway_ip    = "192.168.18.1"
    wan_public_ip = data.dns_a_record_set.ferme.addrs[0]
  }

  interfaces {
    name        = "eth1"
    type        = "LAN"
    ip_address  = "192.168.180.1/24"
    enable_dhcp = false
  }

  interfaces {
    name        = "eth2"
    type        = "MANAGEMENT"
    enable_dhcp = true
  }
}

# Attach edge to transit
resource "aviatrix_edge_spoke_transit_attachment" "edge-ferme-transit-we" {
  spoke_gw_name               = aviatrix_edge_platform.edge-gw-ferme.gw_name
  transit_gw_name             = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.gw_name
  enable_over_private_network = false
  depends_on                  = [aviatrix_edge_platform.edge-gw-ferme]
}

# resource "aviatrix_edge_neo" "edge-studio" {

#   account_name               = local.accounts.csp_account
#   gw_name                    = "edge-studio"
#   site_id                    = "studio"
#   gw_size                    = "small"
#   local_as_number            = 65080
#   device_id                  = aviatrix_edge_neo_device_onboarding.neo-studio.device_id
#   management_interface_names = ["eth0", "eth1"]
#   lan_interface_names        = ["eth2"]
#   wan_interface_names        = ["eth0", "eth1"]

#   interfaces {
#     name          = "eth0"
#     type          = "WAN"
#     ip_address    = "192.168.71.70/24"
#     gateway_ip    = "192.168.71.1"
#     wan_public_ip = data.dns_a_record_set.ferme.addrs[0]
#   }


#   interfaces {
#     name        = "eth1"
#     type        = "LAN"
#     ip_address  = "192.168.80.1/24"
#     enable_dhcp = false
#   }

#   interfaces {
#     name        = "eth2"
#     type        = "MANAGEMENT"
#     enable_dhcp = true
#   }
# }
