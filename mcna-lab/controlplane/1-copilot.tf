module "copilot_build_azure" {
  source                         = "github.com/AviatrixSystems/terraform-modules-copilot.git//copilot_build_azure"
  copilot_name                   = "avx-cplt-${var.azure_r2_location_short}"
  virtual_machine_admin_username = local.copilot.username
  virtual_machine_admin_password = var.admin_password
  use_existing_vnet              = true
  resource_group_name            = module.aviatrix_controller_azure.avx_controller_rg.name
  subnet_id                      = module.aviatrix_controller_azure.avx_controller_subnet[0].id
  virtual_machine_size           = var.copilot_virtual_machine_size
  controller_private_ip          = module.aviatrix_controller_azure.avx_controller_private_ip
  controller_public_ip           = module.aviatrix_controller_azure.avx_controller_public_ip
  location                       = var.azure_r2_location
  default_data_disk_size         = 64

  allowed_cidrs = {
    "tcp_cidrs" = {
      priority = "100"
      protocol = "Tcp"
      ports    = ["443"]
      cidrs    = ["0.0.0.0/0"]
    }
    "udp_cidrs" = {
      priority = "200"
      protocol = "Udp"
      ports    = ["5000", "31283"]
      cidrs    = ["0.0.0.0/0"]
    }
  }

  depends_on = [
    module.aviatrix_controller_azure
  ]
}

output "copilot_public_ip" {
  value = module.copilot_build_azure.public_ip
}

output "copilot_private_ip" {
  value = module.copilot_build_azure.private_ip
}
