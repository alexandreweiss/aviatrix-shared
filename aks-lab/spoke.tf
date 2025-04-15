// DEV SPOKE in R1
module "azr_r1_spoke_aks" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.6.1"
  count   = var.aks_cluster_qty

  cloud            = "Azure"
  name             = "${var.azure_r1_location_short}-spoke-aks-${count.index}"
  vpc_id           = "${azurerm_virtual_network.vnet[count.index].name}:${azurerm_resource_group.aks-lab-rg[count.index].name}:${azurerm_virtual_network.vnet[count.index].guid}"
  gw_subnet        = azurerm_subnet.gw-subnet[count.index].address_prefixes[0]
  use_existing_vpc = true
  region           = var.azure_r1_location
  account          = var.azure_account
  transit_gw       = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.gw_name
  ha_gw            = false
  //network_domain = aviatrix_segmentation_network_domain.dev_nd.domain_name
  single_ip_snat = true
  single_az_ha   = false
  resource_group = azurerm_resource_group.aks-lab-rg[count.index].name

  depends_on = [
    # azurerm_subnet_route_table_association.pod-subnet-rt-assoc,
    azurerm_subnet_route_table_association.aks-subnet-rt-assoc
  ]
}

# module "azr_r1_spoke_aks_nat" {
#   source = "terraform-aviatrix-modules/mc-overlap-nat-spoke/aviatrix"
#   count  = var.aks_cluster_qty

#   spoke_gw_object = module.azr_r1_spoke_aks[count.index].spoke_gateway
#   gw1_snat_addr   = module.azr_r1_spoke_aks[count.index].spoke_gateway.private_ip

#   spoke_cidrs     = [var.vnet_address_space[count.index].pod_cidr]
#   transit_gw_name = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.gw_name

#   depends_on = [
#     module.azr_r1_spoke_aks
#   ]
# }

# output "spoke_aks" {
#   value     = module.azr_r1_spoke_aks
#   sensitive = true
# }
