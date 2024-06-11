data "tfe_outputs" "dataplane" {
  organization = "ananableu"
  workspace    = "aviatrix-shared"
}

data "dns_a_record_set" "controller_ip" {
  host = var.controller_fqdn
}

resource "random_integer" "random_rg" {
  min = 10000
  max = 99999
}
