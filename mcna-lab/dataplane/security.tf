// Segmentation aka. "Network Domain"

resource "aviatrix_segmentation_network_domain" "prd_nd" {
  domain_name = "prd"
}

resource "aviatrix_segmentation_network_domain" "dev_nd" {
  domain_name = "dev"
}

resource "aviatrix_segmentation_network_domain" "vpn_nd" {
  domain_name = "vpn"
}

resource "aviatrix_segmentation_network_domain" "branch_nd" {
  domain_name = "branch"
}

resource "aviatrix_segmentation_network_domain" "sited_nd" {
  domain_name = "siteD"
}

resource "aviatrix_segmentation_network_domain" "sitea_nd" {
  domain_name = "siteA"
}

// Network domain connection policies
resource "aviatrix_segmentation_network_domain_connection_policy" "vpn_prod" {
  domain_name_1 = aviatrix_segmentation_network_domain.vpn_nd.domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.prd_nd.domain_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "vpn_dev" {
  domain_name_1 = aviatrix_segmentation_network_domain.vpn_nd.domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.dev_nd.domain_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "branch_dev" {
  domain_name_1 = aviatrix_segmentation_network_domain.branch_nd.domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.dev_nd.domain_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "branch_prd" {
  domain_name_1 = aviatrix_segmentation_network_domain.branch_nd.domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.prd_nd.domain_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "branch_sitea" {
  domain_name_1 = aviatrix_segmentation_network_domain.branch_nd.domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.sitea_nd.domain_name
}

resource "aviatrix_segmentation_network_domain_connection_policy" "sitea_prd" {
  domain_name_1 = aviatrix_segmentation_network_domain.sitea_nd.domain_name
  domain_name_2 = aviatrix_segmentation_network_domain.prd_nd.domain_name
}


// User VPN
resource "aviatrix_vpn_user" "aweiss" {
  count = local.features.deploy_azr_vpn_gw ? 1 : 0

  user_email = "aweiss@aviatrix.com"
  user_name = "aweiss"
  gw_name = aviatrix_gateway.we-vpn-0[0].gw_name
  vpc_id = aviatrix_gateway.we-vpn-0[0].vpc_id
}


// Smart Groups
resource "aviatrix_app_domain" "catch-all" {
  name = "catch-all"
  selector {
    match_expressions {
      cidr = "0.0.0.0/0"
    }
  }
}

resource "aviatrix_app_domain" "ferme" {
  name = "ferme"
  selector {
    match_expressions {
      cidr = "192.168.16.0/24"
    }
  }
}

resource "aviatrix_app_domain" "app1-front" {
  name = "app1-front"
  selector {
    match_expressions {
      type = "vm"
      tags = {
        environment = "app1-front"
      }
    }
  }
}

resource "aviatrix_app_domain" "app2-front" {
  name = "app2-front"
  selector {
    match_expressions {
      type = "vm"
      tags = {
        environment = "app2-front"
      }
    }
  }
}

resource "aviatrix_app_domain" "dev" {
  name = "dev"
  selector {
    match_expressions {
      type = "vm"
      tags = {
        environment = "dev"
      }
    }
  }
}

resource "aviatrix_microseg_policy_list" "policy" {
  policies {
    action = "DENY"
    src_app_domains = [ aviatrix_app_domain.dev.uuid ]
    name = "DenyDevApp1"
    protocol = "ANY"
    dst_app_domains = [ aviatrix_app_domain.app1-front.uuid ]
    logging = true
    priority = 100
  }
  policies {
    action = "DENY"
    src_app_domains = [ aviatrix_app_domain.app1-front.uuid ]
    name = "DenyApp1ToApp2"
    protocol = "ANY"
    dst_app_domains = [ aviatrix_app_domain.app2-front.uuid ]
    logging = true
    priority = 200
  }
  policies {
    action = "PERMIT"
    src_app_domains = [ aviatrix_app_domain.ferme.uuid ]
    name = "AllowFerme"
    protocol = "ANY"
    dst_app_domains = [ aviatrix_app_domain.catch-all.uuid ]
    logging = true
    priority = 3500
  }
  policies {
    action = "DENY"
    src_app_domains = [ aviatrix_app_domain.catch-all.uuid ]
    name = "DenyAll"
    protocol = "ANY"
    dst_app_domains = [ aviatrix_app_domain.catch-all.uuid ]
    logging = true
    priority = 4000
  }
}
