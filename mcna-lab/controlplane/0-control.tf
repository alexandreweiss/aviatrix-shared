data "dns_a_record_set" "ferme" {
  host = var.ferme_fqdn
}

module "aviatrix_controller_azure" {
  source          = "AviatrixSystems/azure-controller/aviatrix"
  controller_name = "avx-ctrl-${var.azure_r2_location_short}"
  // Example incoming_ssl_cidr list: ["${data.dns_a_record_set.ferme.addrs[0]}/32"]
  incoming_ssl_cidr               = ["${data.dns_a_record_set.ferme.addrs[0]}/32"]
  avx_controller_admin_email      = var.admin_email
  avx_controller_admin_password   = var.admin_password
  account_email                   = var.admin_email
  access_account_name             = var.azure_account
  aviatrix_customer_id            = var.aviatrix_customer_id
  location                        = var.azure_r2_location
  controller_vnet_cidr            = var.controller_vnet_cidr
  controller_subnet_cidr          = var.controller_subnet_cidr
  controller_virtual_machine_size = var.controller_virtual_machine_size
  app_name                        = "avx-ctrl-${var.azure_r2_location_short}-20231023"
}

output "controller_public_ip" {
  value = module.copilot_build_azure.public_ip
}


