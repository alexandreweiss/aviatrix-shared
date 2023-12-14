// Disabled to remove Firewall instance $$
module "azr-firenet_r1" {
  source = "terraform-aviatrix-modules/mc-firenet/aviatrix"
  //version = "v1.4.1"

  transit_module           = data.tfe_outputs.dataplane.values.transit_we
  firewall_image           = "Palo Alto Networks VM-Series Flex Next-Generation Firewall (BYOL)"
  custom_fw_names          = ["azr-${var.azure_r1_location_short}-firenet", "azr-${var.azure_r1_location_short}-firenet-2"]
  egress_enabled           = false
  fw_amount                = 2
  instance_size            = "Standard_D3_v2"
  username                 = var.firewall_admin_username
  password                 = var.admin_password
  bootstrap_storage_name_1 = "avxnesa"
  file_share_folder_1      = "pan-bootstrap"
  storage_access_key_1     = var.storage_access_key
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
