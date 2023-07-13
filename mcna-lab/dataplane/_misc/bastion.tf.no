module "bastion-vn" {
  source = "github.com/alexandreweiss/terraform-azurerm-vnet"
  //version = "4.0"
  count = local.features.deploy_azr_bastion ? 1 : 0

  resource_group_name = "${var.azure_r1_location_short}-bastion-rg"
  address_space       = ["192.168.168.0/26"]
  subnet_names        = ["AzureBastionSubnet"]
  subnet_prefixes     = ["192.168.168.0/26"]
  vnet_location       = var.azure_r1_location
  vnet_name           = "${var.azure_r1_location_short}-bastion-vn"

}

module "we-bastion" {
  source = "github.com/alexandreweiss/misc-tf-modules/bastion"
  count  = local.features.deploy_azr_bastion ? 1 : 0

  location            = var.azure_r1_location
  resource_group_name = "${var.azure_r1_location_short}-bastion-rg"
  subnet_id           = module.bastion-vn[0].vnet_subnets[0]
}

module "bastion-we-spoke-prd-peering" {
  source = "github.com/alexandreweiss/terraform-azurerm-vnetpeering"
  count  = local.features.deploy_azr_we_spoke_prd && local.features.deploy_azr_bastion ? 1 : 0

  left_vnet_resource_group_name  = module.we-bastion[0].resource_group_name
  left_vnet_name                 = module.bastion-vn[0].vnet_name
  right_vnet_resource_group_name = azurerm_resource_group.azr-r1-spoke-prd-rg.name
  right_vnet_name                = azurerm_virtual_network.azure-spoke-prd-r1.name

  depends_on = [
    module.bastion-vn
  ]
}

module "bastion-we-spoke-dev-peering" {
  source = "github.com/alexandreweiss/terraform-azurerm-vnetpeering"
  count  = local.features.deploy_azr_we_spoke_dev && local.features.deploy_azr_bastion ? 1 : 0

  left_vnet_resource_group_name  = module.we-bastion[0].resource_group_name
  left_vnet_name                 = module.bastion-vn[0].vnet_name
  right_vnet_resource_group_name = azurerm_resource_group.azr-r1-spoke-dev-rg.name
  right_vnet_name                = azurerm_virtual_network.azure-spoke-dev-r1.name
  depends_on = [
    module.bastion-vn
  ]
}
