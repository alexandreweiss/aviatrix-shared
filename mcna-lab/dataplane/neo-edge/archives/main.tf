// Retrieve the transit
data "tfe_outputs" "dataplane" {
  organization = "ananableu"
  workspace    = "aviatrix-shared"
}

output "transit_we" {
  value     = data.tfe_outputs.dataplane.values.transit_we
  sensitive = true
}

data "dns_a_record_set" "ferme" {
  host = var.ferme_fqdn
}

# Onboard an Edge NEO device
resource "aviatrix_edge_neo_device_onboarding" "neo-devices" {
  for_each = local.devices_map

  account_name   = local.accounts.csp_account
  device_name    = each.value.name
  serial_number  = each.value.serial_number
  hardware_model = each.value.hardware_model
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
    enable_dhcp    = false
    //ipv4_cidr       = "172.16.15.162/20"
    //gateway_ip      = "172.16.0.1"
    //dns_server_ips  = ["172.16.0.1"]

  }
}

# Create an Edge NEO
resource "aviatrix_edge_neo" "neo-edges" {
  for_each = local.edges_map

  account_name               = local.accounts.csp_account
  gw_name                    = each.value.gw_name
  site_id                    = each.value.site_id
  device_id                  = aviatrix_edge_neo_device_onboarding.neo-devices.[each.value.neo_device].device_id
  gw_size                    = each.value.gw_size
  management_interface_names = ["eth0", "eth1"]
  lan_interface_names        = ["eth2"]
  wan_interface_names        = ["eth0", "eth1"]
  local_as_number            = each.value.local_as_number
  interfaces {
    name          = "eth0"
    type          = "WAN"
    ip_address    = each.value.wan_ip
    gateway_ip    = each.value.wan_gw_ip
    wan_public_ip = data.dns_a_record_set.ferme.addrs[0]
  }

  interfaces {
    name        = "eth1"
    type        = "LAN"
    ip_address  = each.value.lan_ip
    enable_dhcp = false
  }

  interfaces {
    name        = "eth2"
    type        = "MANAGEMENT"
    enable_dhcp = true
  }
}
