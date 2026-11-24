# BGP peers of the Cato transit site (228022). They were created by hand; imported here so the
# metric (route preference inside Cato, lower is preferred) can be set per PoP.
# Idea under test: with the transit on both PoPs, Cato spreads inbound flows over all 4 peers;
# a higher metric on the PoP 2 peers should make Cato prefer PoP 1 inbound (symmetric with the
# transit's own preference for PoP 1).

variable "transit_pop2_peer_metric" {
  description = "Cato BGP peer metric for the transit's PoP 2 peers (50-255, lower is preferred). 100 = same as PoP 1 (no preference)."
  type        = number
  default     = 200
}

locals {
  transit_bgp_peers = {
    pop1-gw   = { id = "30613", ip = "192.168.20.1", name = "avx-primary-cato-pri-2", pop = 1 }
    pop1-hagw = { id = "30614", ip = "192.168.20.5", name = "avx-sec-cato-sec-2", pop = 1 }
    pop2-gw   = { id = "30579", ip = "192.168.20.9", name = "avx-primary-cato-pri", pop = 2 }
    pop2-hagw = { id = "30610", ip = "192.168.20.13", name = "avx-sec-cato-sec", pop = 2 }
  }
}

import {
  for_each = local.transit_bgp_peers
  to       = cato_bgp_peer.transit[each.key]
  id       = each.value.id
}

resource "cato_bgp_peer" "transit" {
  for_each = local.transit_bgp_peers

  site_id                 = cato_ipsec_site.spoke.id
  name                    = each.value.name
  cato_asn                = var.cato_asn
  peer_asn                = 65007
  peer_ip                 = each.value.ip
  default_action          = "ACCEPT"
  metric                  = each.value.pop == 2 ? var.transit_pop2_peer_metric : 100
  hold_time               = 60
  keepalive_interval      = 20
  advertise_all_routes    = true
  advertise_default_route = false

  lifecycle {
    ignore_changes = [bfd_settings, md5_auth_key, summary_route]
  }
}
