module "aviatrix_controller_azure" {
   source                        = "AviatrixSystems/azure-controller/aviatrix"
   controller_name               = "avx-ctrl-ne"
   // Example incoming_ssl_cidr list: ["95.178.110.82/32"]
   incoming_ssl_cidr             = ["0.0.0.0/0"]
   avx_controller_admin_email    = local.controller.admin_email
   avx_controller_admin_password = var.admin_password
   account_email                 = local.controller.admin_email
   access_account_name           = local.accounts.azure_account
   aviatrix_customer_id          = var.aviatrix_customer_id
   location                      = var.azure_we_location
   controller_vnet_cidr          = var.controller_vnet_cidr
   controller_subnet_cidr          = var.controller_subnet_cidr
   controller_virtual_machine_size = var.controller_virtual_machine_size
}