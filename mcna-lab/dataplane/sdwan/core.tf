// Retrieve the transit informations
data "tfe_outputs" "dataplane" {
  organization = "ananableu"
  workspace    = "aviatrix-shared"
}

data "dns_a_record_set" "controller_ip" {
  host = var.controller_fqdn
}

data "azurerm_subscription" "current" {}
