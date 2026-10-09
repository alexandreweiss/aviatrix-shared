module "azr-firenet_r1_1" {
  source = "terraform-aviatrix-modules/mc-firenet/aviatrix"

  transit_module  = data.tfe_outputs.dataplane.values.transit_we_1
  firewall_image  = "Check Point CloudGuard IaaS Single Gateway R82.20 - Bring Your Own License"
  custom_fw_names = ["azr-ci-firenet-ipv4"]
  egress_enabled  = false
  fw_amount       = 2
  instance_size   = "Standard_D2s_v5"
  username        = var.firewall_admin_username
}
