// Disabled to remove Firewall instance $$
module "aws_firenet_r1" {
  source = "terraform-aviatrix-modules/mc-firenet/aviatrix"

  transit_module = data.tfe_outputs.dataplane.values.aws_transit_r1
  # firewall_image = "Palo Alto Networks VM-Series Next-Generation Firewall (BYOL)"
  firewall_image = "Fortinet FortiGate (BYOL) Next-Generation Firewall"
  # custom_fw_names = ["aws-${var.aws_r1_location_short}-firenet-1", "aws-${var.aws_r1_location_short}-firenet-2"]
  # fw_amount       = 2
  custom_fw_names = ["aws-${var.aws_r1_location_short}-firenet-1"]
  egress_enabled  = false
  # bootstrap_bucket_name_1 = "avxfras3"
  # iam_role_1              = "AviatrixBootstrapRole"
  # username = var.firewall_admin_username
  # password = var.admin_password
  tags = {
    csp-environment : "tst",
    csp-department : "dept-530",
    shutdown : "stop",
    schedule : "08:00-11:00;mo,tu,we,th,fr;europe-paris"
  }
}

// Disabled because of bug in identifying correct subnet 
# module "azr-r1-firenet-egress" {
#   source = "terraform-aviatrix-modules/mc-firenet/aviatrix"
#   //version = "v1.3.0"

#   transit_module  = module.azure_transit_we_egress
#   firewall_image  = "aviatrix"
#   custom_fw_names = ["azr-${var.azure_r1_location_short}-firenet-egress"]
#   egress_enabled  = true
#   instance_size   = "Standard_B1ms"
# }
