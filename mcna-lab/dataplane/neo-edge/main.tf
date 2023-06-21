// Retrieve the transit
data "tfe_outputs" "dataplane" {
  organization = "ananableu"
  workspace    = "aviatrix-shared"
}

data "dns_a_record_set" "ferme" {
  host = var.ferme_fqdn
}

# NEO 1 WAN / VMWARE
resource "aviatrix_edge_neo_device_onboarding" "neo-ferme-1wan" {

  account_name   = local.accounts.csp_account
  device_name    = "neo-ferme-1wan"
  serial_number  = "VMware-56 4d 31 3e 8f 40 54 34-46 ca 77 83 00 d5 e5 eb"
  hardware_model = "ESXI-VM-1-WAN"
  //management_egress_ip_prefix_list = "[${data.dns_a_record_set.ferme.addrs[0]}]"

  network {
    interface_name = "eth0"
    enable_dhcp    = true
    //ipv4_cidr       = "172.16.15.162/20"
    //gateway_ip      = "172.16.0.1"
    //dns_server_ips  = ["172.16.0.1"]

  }

  network {
    interface_name = "eth1"
    enable_dhcp    = true
    //ipv4_cidr       = "172.16.15.162/20"
    //gateway_ip      = "172.16.0.1"
    //dns_server_ips  = ["172.16.0.1"]

  }
}

# Onboard an Edge NEO device
resource "aviatrix_edge_neo_device_onboarding" "neo-ferme" {

  account_name   = local.accounts.csp_account
  device_name    = "neo-ferme"
  serial_number  = "VMware-56 4d f0 d5 c0 a6 59 d1-bd 28 12 3f fe 7f a6 f0"
  hardware_model = "ESXI-VM-2-WAN"
  //management_egress_ip_prefix_list = "[${data.dns_a_record_set.ferme.addrs[0]}]"

  network {
    interface_name = "eth0"
    enable_dhcp    = true
    //ipv4_cidr       = "172.16.15.162/20"
    //gateway_ip      = "172.16.0.1"
    //dns_server_ips  = ["172.16.0.1"]

  }

  network {
    interface_name = "eth1"
    enable_dhcp    = true
    //ipv4_cidr       = "172.16.15.162/20"
    //gateway_ip      = "172.16.0.1"
    //dns_server_ips  = ["172.16.0.1"]

  }

  network {
    interface_name = "eth2"
    enable_dhcp    = true
    //ipv4_cidr       = "172.16.15.162/20"
    //gateway_ip      = "172.16.0.1"
    //dns_server_ips  = ["172.16.0.1"]

  }
}

# resource "aviatrix_edge_neo_device_onboarding" "neo-studio" {

#   account_name   = local.accounts.csp_account
#   device_name    = "neo-studio"
#   serial_number  = "26b2e4a4-eb44-4712-9c69-8095a4394d44"
#   hardware_model = "ESXI-VM-2-WAN"
#   //management_egress_ip_prefix_list = "[${data.dns_a_record_set.ferme.addrs[0]}]"

#   network {
#     interface_name = "eth0"
#     enable_dhcp    = true
#     //ipv4_cidr       = "172.16.15.162/20"
#     //gateway_ip      = "172.16.0.1"
#     //dns_server_ips  = ["172.16.0.1"]

#   }

#   network {
#     interface_name = "eth1"
#     enable_dhcp    = true
#     //ipv4_cidr       = "172.16.15.162/20"
#     //gateway_ip      = "172.16.0.1"
#     //dns_server_ips  = ["172.16.0.1"]

#   }

#   network {
#     interface_name = "eth2"
#     enable_dhcp    = true
#     //ipv4_cidr       = "172.16.15.162/20"
#     //gateway_ip      = "172.16.0.1"
#     //dns_server_ips  = ["172.16.0.1"]

#   }
# }

# Create an Edge NEO
resource "aviatrix_edge_neo" "edge-ferme" {

  account_name               = local.accounts.csp_account
  gw_name                    = "edge-ferme"
  site_id                    = "ferme"
  gw_size                    = "small"
  local_as_number            = 65061
  device_id                  = aviatrix_edge_neo_device_onboarding.neo-ferme.device_id
  management_interface_names = ["eth0", "eth1"]
  lan_interface_names        = ["eth2"]
  wan_interface_names        = ["eth0", "eth1"]



  interfaces {
    name          = "eth0"
    type          = "WAN"
    ip_address    = "192.168.60.160/24"
    gateway_ip    = "192.168.60.1"
    wan_public_ip = data.dns_a_record_set.ferme.addrs[0]
  }

  interfaces {
    name        = "eth1"
    type        = "LAN"
    ip_address  = "192.168.61.1/24"
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
  spoke_gw_name   = aviatrix_edge_neo.edge-ferme.gw_name
  transit_gw_name = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.gw_name
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
