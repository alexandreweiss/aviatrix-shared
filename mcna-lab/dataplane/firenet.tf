module "azr-we-firenet" {
  source  = "terraform-aviatrix-modules/mc-firenet/aviatrix"
  //version = "v1.3.0"

  transit_module = module.azure_transit_we
  firewall_image = "Palo Alto Networks VM-Series Flex Next-Generation Firewall (BYOL)"
  custom_fw_names = ["azr-we-firenet","azr-we-firenet-2"]
  egress_enabled = true
  fw_amount = 2
  instance_size = "Standard_D3_v2"
  username = var.firewall_admin_username
  password = var.admin_password
}