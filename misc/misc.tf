provider "aviatrix" {
  username                = "admin"
  password                = "CharlesAvi-123"
  controller_ip           = "controller-prd.ananableu.fr"
  skip_version_validation = true
}

terraform {
  required_providers {
    aviatrix = {
      source = "aviatrixsystems/aviatrix"
    }
  }
}

resource "aviatrix_gateway_dnat" "example" {
  gw_name = "in-gw"

  dnat_policy {
    src_cidr          = "209.59.174.216/32"
    dst_cidr          = "52.186.41.149/32"
    dst_port          = 18001
    protocol          = "tcp"
    mark              = "66000"
    dnat_ips          = "10.185.83.75"
    dnat_port         = 8001
    interface         = "eth0"
    apply_route_entry = false
  }
}


resource "aviatrix_gateway_snat" "snat_gw2" {
  gw_name   = "in-gw"
  snat_mode = "customized_snat"
  snat_policy {
    protocol          = "tcp"
    mark              = "66000"
    snat_ips          = "10.10.0.38"
    connection        = "None"
    interface         = "eth0"
    apply_route_entry = false
  }
}
