resource "aviatrix_gateway" "r1-vpn-0" {
  count = 1

  cloud_type          = 16
  account_name        = var.oci_account
  gw_name             = "${var.oci_r1_location_short}-vpn-${var.customer_name}-${count.index}"
  vpc_id              = "ocid1.vcn.oc1.eu-paris-1.amaaaaaamjkdzoqaq5juvllmd5k3pese65t6s6exu5akqzagb6gbfymlba3q"
  vpc_reg             = var.oci_r1_location
  gw_size             = "VM.E4.Flex.4.16"
  subnet              = "10.54.0.32/28"
  vpn_access          = true
  vpn_cidr            = "172.20.2${count.index}.0/24"
  additional_cidrs    = "10.0.0.0/8"
  max_vpn_conn        = "100"
  split_tunnel        = true
  enable_vpn_nat      = true
  availability_domain = "aD:EU-PARIS-1-AD-1"
  fault_domain        = "FAULT-DOMAIN-1"
}

// User VPN
resource "aviatrix_vpn_user" "aweiss" {

  user_email = "aweiss@aviatrix.com"
  user_name  = "aweiss"
  gw_name    = aviatrix_gateway.r1-vpn-0[0].gw_name
  vpc_id     = "ocid1.vcn.oc1.eu-paris-1.amaaaaaamjkdzoqaq5juvllmd5k3pese65t6s6exu5akqzagb6gbfymlba3q"

  depends_on = [aviatrix_gateway.r1-vpn-0]
}
