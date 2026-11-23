data "dns_a_record_set" "controller_ip" {
  host = var.controller_fqdn
}

data "tfe_outputs" "dataplane" {
  organization = "ananableu"
  workspace    = "aviatrix-shared"
}

data "tfe_outputs" "spoke" {
  organization = "ananableu"
  workspace    = "aviatrix-shared-spoke"
}

data "cato_allocatedIp" "pops" {
  name_filter = var.cato_pop_ips
}

data "cato_siteLocation" "pune" {
  filters = [
    {
      field     = "city"
      search    = "Pune"
      operation = "startsWith"
    },
    {
      field     = "country_name"
      search    = "India"
      operation = "contains"
    },
  ]
}

locals {
  spoke = nonsensitive(data.tfe_outputs.spoke.values.spoke_app2.spoke_gateway)

  # Cato allocated IP id per PoP public IP
  pop_id = { for i in data.cato_allocatedIp.pops.items : i.name => i.id }

  # Tunnel /30s: next free after 192.168.20.0-15 used by the transit tunnels.
  # site = Aviatrix spoke side, cato = Cato side (first / second usable host).
  tunnels = {
    primary = {
      pop = var.cato_pop_ips[0]
      gw = [
        { spoke_ip = local.spoke.eip, site = "192.168.20.17", cato = "192.168.20.18" },
        { spoke_ip = local.spoke.ha_eip, site = "192.168.20.21", cato = "192.168.20.22" },
      ]
    }
    secondary = {
      pop = var.cato_pop_ips[1]
      gw = [
        { spoke_ip = local.spoke.eip, site = "192.168.20.25", cato = "192.168.20.26" },
        { spoke_ip = local.spoke.ha_eip, site = "192.168.20.29", cato = "192.168.20.30" },
      ]
    }
  }
}

# ------------------------------------------------- Existing Cato site (TRANSIT)
# Imported site 228022: its IPsec tunnels to the Aviatrix transit are managed here.
# Name, location, range and type stay as they are in Cato (ignored). Cato allows at most
# 3 tunnels per PoP group, so the spoke has its own site below.
locals {
  # Tunnels from the transit gateways (site = Aviatrix side, cato = Cato side)
  transit_tunnels = {
    primary = [
      { public_site_ip = "135.13.176.96", site = "192.168.20.1", cato = "192.168.20.2" },
      { public_site_ip = "20.204.189.186", site = "192.168.20.5", cato = "192.168.20.6" },
    ]
    secondary = [
      { public_site_ip = "135.13.176.96", site = "192.168.20.9", cato = "192.168.20.10" },
      { public_site_ip = "20.204.189.186", site = "192.168.20.13", cato = "192.168.20.14" },
    ]
  }
}

resource "cato_ipsec_site" "spoke" {
  name                 = var.cato_transit_site_name
  site_type            = "CLOUD_DC"
  description          = "imported"
  native_network_range = "10.10.4.0/23"
  site_location = {
    city         = "Pune"
    country_code = "IN"
    state_code   = "IN-MH"
    timezone     = "Asia/Kolkata"
    address      = ""
  }

  ipsec = {
    connection_mode = "BIDIRECTIONAL"
    init_message = {
      cipher    = "AES_CBC_256"
      dh_group  = "DH_14_MODP2048"
      integrity = "SHA256"
      prf       = "SHA256"
    }
    auth_message = {
      cipher    = "AES_CBC_256"
      dh_group  = "DH_14_MODP2048"
      integrity = "SHA256"
      prf       = "SHA256"
    }
    primary = {
      public_cato_ip_id = local.pop_id[local.tunnels.primary.pop]
      tunnels = [for t in local.transit_tunnels.primary : {
        public_site_ip  = t.public_site_ip
        private_cato_ip = t.cato
        private_site_ip = t.site
        psk             = var.cato_ipsec_psk
        last_mile_bw    = { downstream = 100, upstream = 100 }
      }]
    }
    secondary = {
      public_cato_ip_id = local.pop_id[local.tunnels.secondary.pop]
      tunnels = [for t in local.transit_tunnels.secondary : {
        public_site_ip  = t.public_site_ip
        private_cato_ip = t.cato
        private_site_ip = t.site
        psk             = var.cato_ipsec_psk
        last_mile_bw    = { downstream = 100, upstream = 100 }
      }]
    }
  }

  lifecycle {
    ignore_changes = [name, site_location, site_type, description, native_network_range]
  }
}

# ---------------------------------------------------- New Cato site (MyApp2 spoke)
resource "cato_ipsec_site" "myapp2" {
  name                 = var.cato_site_name
  site_type            = "CLOUD_DC"
  description          = "Azure Central India - Aviatrix MyApp2 spoke BGPoIPsec"
  native_network_range = var.cato_native_network_range
  site_location = {
    city         = data.cato_siteLocation.pune.locations[0].city
    country_code = data.cato_siteLocation.pune.locations[0].country_code
    state_code   = data.cato_siteLocation.pune.locations[0].state_code
    timezone     = data.cato_siteLocation.pune.locations[0].timezone[0]
    address      = "Azure Central India"
  }

  ipsec = {
    connection_mode = "BIDIRECTIONAL"
    init_message = {
      cipher    = "AES_CBC_256"
      dh_group  = "DH_14_MODP2048"
      integrity = "SHA256"
      prf       = "SHA256"
    }
    auth_message = {
      cipher    = "AES_CBC_256"
      dh_group  = "DH_14_MODP2048"
      integrity = "SHA256"
      prf       = "SHA256"
    }
    primary = {
      public_cato_ip_id = local.pop_id[local.tunnels.primary.pop]
      tunnels = [for t in local.tunnels.primary.gw : {
        public_site_ip  = t.spoke_ip
        private_cato_ip = t.cato
        private_site_ip = t.site
        psk             = var.cato_ipsec_psk
        last_mile_bw    = { downstream = 100, upstream = 100 }
      }]
    }
    secondary = {
      public_cato_ip_id = local.pop_id[local.tunnels.secondary.pop]
      tunnels = [for t in local.tunnels.secondary.gw : {
        public_site_ip  = t.spoke_ip
        private_cato_ip = t.cato
        private_site_ip = t.site
        psk             = var.cato_ipsec_psk
        last_mile_bw    = { downstream = 100, upstream = 100 }
      }]
    }
  }
}

# One BGP peer per tunnel (peer_ip = Aviatrix side of the tunnel)
resource "cato_bgp_peer" "spoke" {
  for_each = {
    for p in flatten([
      for grp, v in local.tunnels : [
        for idx, t in v.gw : { key = "${grp}-${idx}", ip = t.site }
      ]
    ]) : p.key => p.ip
  }

  site_id        = cato_ipsec_site.myapp2.id
  name           = "avx-myapp2-${each.key}"
  cato_asn       = var.cato_asn
  peer_asn       = 65012
  peer_ip        = each.value
  default_action = "ACCEPT"
  metric         = startswith(each.key, "primary") ? var.metric_primary : var.metric_backup

  advertise_all_routes    = true
  advertise_default_route = false

  lifecycle {
    ignore_changes = [bfd_settings, md5_auth_key, summary_route]
  }
}

# ------------------------------------------------------------ Aviatrix side
# One dedicated connection per Cato PoP (no backup peer). With an HA spoke, Aviatrix
# ActiveMesh still builds a tunnel from each spoke gateway to the PoP, so each
# connection has 2 tunnels (spoke primary + spoke HA).
resource "aviatrix_spoke_external_device_conn" "cato" {
  # Only the PoPs listed in var.active_pops get an Aviatrix connection
  for_each = {
    for k, v in { primary = "pop1", secondary = "pop2" } : k => v
    if contains(var.active_pops, k)
  }

  vpc_id            = local.spoke.vpc_id
  gw_name           = local.spoke.gw_name
  connection_name   = "Cato-MyApp2-${each.value}"
  connection_type   = "bgp"
  tunnel_protocol   = "IPSEC"
  enable_ikev2      = true
  bgp_local_as_num  = "65012"
  bgp_remote_as_num = tostring(var.cato_asn)

  # Algorithms: Aviatrix defaults already are AES-256-CBC / SHA-256 / DH 14 for both
  # phases, so custom_algorithms is left off (it is rejected when all six values are
  # defaults). The Cato site sets the same values explicitly (init/auth message).

  remote_gateway_ip  = local.tunnels[each.key].pop
  local_tunnel_cidr  = join(",", [for t in local.tunnels[each.key].gw : "${t.site}/30"])
  remote_tunnel_cidr = join(",", [for t in local.tunnels[each.key].gw : "${t.cato}/30"])
  pre_shared_key     = var.cato_ipsec_psk
  ha_enabled         = false

  # Optional: prepend our AS on the PoP 2 connection to make it a backup (empty = active/active
  # advertisements; Cato itself still prefers its primary PoP by default).
  prepend_as_path = each.key == "secondary" && length(var.backup_prepend_as_path) > 0 ? var.backup_prepend_as_path : null

  depends_on = [cato_ipsec_site.myapp2]
}

# ------------------------------------------- Aviatrix side of the TRANSIT <-> Cato link
# Same PSK variable (cato_ipsec_psk) as the Cato sites and the MyApp2 connection.
# One dedicated connection per PoP; only the PoPs in var.transit_active_pops are built.
# With an HA transit, each connection has 2 tunnels (transit primary + transit HA).
resource "aviatrix_transit_external_device_conn" "transit" {
  for_each = {
    for k, v in { primary = "pop1", secondary = "pop2" } : k => v
    if contains(var.transit_active_pops, k)
  }

  vpc_id            = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.vpc_id
  gw_name           = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.gw_name
  connection_name   = "Cato-${each.value}"
  connection_type   = "bgp"
  tunnel_protocol   = "IPSEC"
  enable_ikev2      = true
  bgp_local_as_num  = "65007"
  bgp_remote_as_num = tostring(var.cato_asn)

  remote_gateway_ip  = local.tunnels[each.key].pop
  local_tunnel_cidr  = join(",", [for t in local.transit_tunnels[each.key] : "${t.site}/30"])
  remote_tunnel_cidr = join(",", [for t in local.transit_tunnels[each.key] : "${t.cato}/30"])
  pre_shared_key     = var.cato_ipsec_psk
  ha_enabled         = false

  depends_on = [cato_ipsec_site.spoke]
}

output "cato_site_id" {
  value = cato_ipsec_site.myapp2.id
}
