# module "ne-prd-vm" {
#   count = local.features.deploy_azr_ne_spoke ? 1 : 0
#   source = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
#   environment = "prd"
#   location = var.azure_r2_location
#   location_short = var.azure_r2_location_short
#   index_number = 01
#   resource_group_name = azurerm_resource_group.avx-lab-vms-rg.name
#   subnet_id = module.ne_spoke_prd[0].vpc.subnets[3].subnet_id
#   admin_ssh_key = var.ssh_public_key
# }

module "we-prd-vm" {
  source              = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
  environment         = "prd"
  location            = var.azure_r1_location
  location_short      = var.azure_r1_location_short
  index_number        = 01
  resource_group_name = azurerm_resource_group.avx-lab-vms-rg.name
  subnet_id           = azurerm_subnet.r1-azure-spoke-prd-vm-subnet.id
  admin_ssh_key       = var.ssh_public_key
  depends_on = [
    module.we_spoke_prd
  ]
}

# module "we-app1-front-vm" {
#   source              = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
#   environment         = "app1-front"
#   location            = var.azure_r1_location
#   location_short      = var.azure_r1_location_short
#   index_number        = 01
#   resource_group_name = azurerm_resource_group.avx-lab-vms-rg.name
#   subnet_id           = module.we_spoke_prd[0].vpc.subnets[3].subnet_id
#   admin_ssh_key       = var.ssh_public_key
#   depends_on = [
#     module.we_spoke_prd
#   ]
# }

# module "we-app2-front-vm" {
#   source              = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
#   environment         = "app2-front"
#   location            = var.azure_r1_location
#   location_short      = var.azure_r1_location_short
#   index_number        = 01
#   resource_group_name = azurerm_resource_group.avx-lab-vms-rg.name
#   subnet_id           = module.we_spoke_prd[0].vpc.subnets[3].subnet_id
#   admin_ssh_key       = var.ssh_public_key
#   depends_on = [
#     module.we_spoke_prd
#   ]
# }

module "we-dev-vm" {
  source              = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
  environment         = "dev"
  location            = var.azure_r1_location
  location_short      = var.azure_r1_location_short
  index_number        = 01
  resource_group_name = azurerm_resource_group.avx-lab-vms-rg.name
  subnet_id           = azurerm_subnet.r1-azure-spoke-dev-vm-subnet.id
  admin_ssh_key       = var.ssh_public_key
  depends_on = [
    module.we_spoke_dev
  ]
}
