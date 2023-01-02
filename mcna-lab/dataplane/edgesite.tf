# module "edge-site-a" {
#   source  = "terraform-aviatrix-modules/mc-edge/aviatrix"
#   version = "v1.1.2"

#   site_id        = "siteA"
#   network_domain = "siteA"

#   edge_gws = {
#     gw1 = {
#       gw_name                 = "edge-site-a",
#       lan_interface_ip_prefix = "192.168.61.1/24",
#       transit_gws = {
#         transit1 = {
#           name                        = module.azure_transit_we.transit_gateway.gw_name,
#           attached                    = true,
#           enable_jumbo_frame          = false,
#           enable_over_private_network = true
#         }
#       }
#       wan_default_gateway_ip  = "192.168.17.1"
#       wan_interface_ip_prefix = "192.168.17.61/24"
#       management_egress_ip_prefix = "${data.dns_a_record_set.ferme.addrs[0]}/32"
#       local_as_number         = "65061"
#       //wan_public_ip           = "${data.dns_a_record_set.ferme.addrs[0]}"
#     } 
#   }
# }

# resource "aviatrix_edge_spoke_external_device_conn" "edge-siteA-lan" {
#   site_id           = "siteA"
#   connection_name   = "lanSiteA"
#   gw_name           = "edge-site-a"
#   bgp_local_as_num  = "65061"
#   bgp_remote_as_num = "65161"
#   local_lan_ip      = "192.168.61.1"
#   remote_lan_ip     = "192.168.61.2"
# }

module "edge-site-b" {
  source  = "terraform-aviatrix-modules/mc-edge/aviatrix"
  //version = "v1.1.2"

  site_id        = "siteB"
  //network_domain = "siteB"

  edge_gws = {
    gw1 = {
      gw_name                 = "edge-site-b",
      lan_interface_ip_prefix = "192.168.62.1/24",
      transit_gws = {
        transit1 = {
          name                        = module.azure_transit_we.transit_gateway.gw_name,
          attached                    = false,
          enable_jumbo_frame          = false,
          enable_over_private_network = true
        }
      }
      wan_default_gateway_ip  = "192.168.17.1"
      wan_interface_ip_prefix = "192.168.17.62/24"
      management_egress_ip_prefix = "${data.dns_a_record_set.ferme.addrs[0]}/32"
      local_as_number         = "65062"
      //wan_public_ip           = "${data.dns_a_record_set.ferme.addrs[0]}"
    } 
  }
}

# module "edge-site-d" {
#   source  = "terraform-aviatrix-modules/mc-edge/aviatrix"
#   version = "v1.1.2"

#   site_id        = "siteD"
#   network_domain = "siteD"

#   edge_gws = {
#     gw1 = {
#       gw_name                 = "edge-site-d",
#       lan_interface_ip_prefix = "192.168.193.2/24",
#       transit_gws = {
#         transit1 = {
#           name               = module.azure_transit_we.transit_gateway.gw_name,
#           attached           = false,
#           enable_jumbo_frame = false
#         }
#       }
#       wan_default_gateway_ip  = "192.168.192.1"
#       wan_interface_ip_prefix = "192.168.192.2/24"
#       management_interface_ip_prefix = "192.168.194.2/24"
#     }
#   }
# }