// Disabled to remove Firewall instance $$
module "gcp-firenet_r1" {
  source = "terraform-aviatrix-modules/mc-firenet/aviatrix"

  transit_module = data.tfe_outputs.dataplane.values.transit_gcp_r1
  firewall_image = "Palo Alto Networks VM-Series Next-Generation Firewall BYOL"
  # custom_fw_names          = ["azr-${var.azure_r1_location_short}-firenet", "azr-${var.azure_r1_location_short}-firenet-2"]
  custom_fw_names = ["gcp-${var.gcp_r1_location_short}-firenet"]
  egress_enabled  = false
  # fw_amount                = 2
  # instance_size            = "Standard_D3_v2"
  username = var.firewall_admin_username
  password = var.admin_password
  # bootstrap_bucket_name_1 = "avxfwbucket" 
  egress_cidr = "10.30.3.0/24"
  mgmt_cidr   = "10.30.4.0/24"
}

# module "azr-firenet-2_r1" {
#   source  = "terraform-aviatrix-modules/mc-firenet/aviatrix"
#   version = "v1.5.3"

#   transit_module  = data.tfe_outputs.dataplane.values.transit_we_egress
#   firewall_image  = "Palo Alto Networks VM-Series Flex Next-Generation Firewall (BYOL)"
#   custom_fw_names = ["azr-${var.azure_r1_location_short}-firenet-eg"]
#   egress_enabled  = true
#   # fw_amount                = 2
#   instance_size            = "Standard_D3_v2"
#   username                 = var.firewall_admin_username
#   password                 = var.admin_password
#   bootstrap_storage_name_1 = "avxnesa"
#   file_share_folder_1      = "pan-bootstrap"
#   storage_access_key_1     = var.storage_access_key
# }

// Disabled because of bug in identifying correct subnet 
# module "azr-r1-firenet-egress" {
#   source = "terraform-aviatrix-modules/mc-firenet/aviatrix"
#   //version = "v1.3.0"

#   transit_module  = data.tfe_outputs.dataplane.values.transit_we_egress
#   firewall_image  = "aviatrix"
#   custom_fw_names = ["azr-${var.azure_r1_location_short}-firenet-egress"]
#   egress_enabled  = true
#   instance_size   = "Standard_B1ms"
# }
