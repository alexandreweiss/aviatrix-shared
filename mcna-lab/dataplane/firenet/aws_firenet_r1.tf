// Disabled to remove Firewall instance $$
module "aws_firenet_r1" {
  source = "terraform-aviatrix-modules/mc-firenet/aviatrix"
  //version = "v1.4.1"

  transit_module  = data.tfe_outputs.dataplane.values.aws_transit_r1
  firewall_image  = "Palo Alto Networks VM-Series Next-Generation Firewall (BYOL)"
  custom_fw_names = ["aws-${var.aws_r1_location_short}-firenet-1", "aws-${var.aws_r1_location_short}-firenet-2"]
  egress_enabled  = false
  fw_amount       = 2
  username        = var.firewall_admin_username
  password        = var.admin_password
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
