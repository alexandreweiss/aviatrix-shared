data "dns_a_record_set" "ferme" {
  host = var.ferme_fqdn
}

data "dns_a_record_set" "controller_ip" {
  host = var.controller_fqdn
}

data "tfe_outputs" "dataplane" {
  organization = "ananableu"
  workspace    = "aviatrix-shared"
}

data "tfe_outputs" "dataplane-spoke" {
  organization = "ananableu"
  workspace    = "aviatrix-shared-spoke"
}
