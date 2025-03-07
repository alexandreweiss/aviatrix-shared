# Peering from ars-transit to ARS #1
module "vn-peering" {
  source = "github.com/alexandreweiss/terraform-azurerm-vnetpeering"

  left_vnet_resource_group_name  = azurerm_resource_group.ars-lab-r1.name
  left_vnet_name                 = azurerm_virtual_network.ars-vn.name
  right_vnet_resource_group_name = azurerm_resource_group.ars-lab-r1.name
  right_vnet_name                = module.azure_transit_ars.vpc.name
  allow_forwarded_traffic        = true
  left_allow_gateway_transit     = true
  left_use_remote_gateways       = false
  right_allow_gateway_transit    = false
  right_use_remote_gateways      = true

  depends_on = [
    azurerm_virtual_network.ars-vn,
    module.azure_transit_ars
  ]
}

#Peering from Aviatrix ARS to Spoke (not needed)

# module "spoke-vn-peering" {
#   source = "github.com/alexandreweiss/terraform-azurerm-vnetpeering"

#   left_vnet_resource_group_name  = azurerm_resource_group.ars-lab-r1.name
#   left_vnet_name                 = azurerm_virtual_network.ars-vn.name
#   right_vnet_resource_group_name = azurerm_resource_group.ars-lab-r1.name
#   right_vnet_name                = azurerm_virtual_network.spoke-vn.name
#   allow_forwarded_traffic        = true
#   left_allow_gateway_transit     = true
#   left_use_remote_gateways       = false
#   right_allow_gateway_transit    = false
#   right_use_remote_gateways      = true


#   depends_on = [
#     azurerm_virtual_network.ars-vn,
#     azurerm_virtual_network.spoke-vn
#   ]
# }

# Peering from FW to spoke #2
module "spoke-vn-fw-peering" {
  source = "github.com/alexandreweiss/terraform-azurerm-vnetpeering"

  left_vnet_resource_group_name  = azurerm_resource_group.ars-lab-r1.name
  left_vnet_name                 = azurerm_virtual_network.fw-vn.name
  right_vnet_resource_group_name = azurerm_resource_group.ars-lab-r1.name
  right_vnet_name                = azurerm_virtual_network.spoke-vn.name
  allow_forwarded_traffic        = true


  depends_on = [
    azurerm_virtual_network.fw-vn,
    azurerm_virtual_network.spoke-vn
  ]
}

# Peering from ARS FW to spoke #3
module "spoke-vn-peering" {
  source = "github.com/alexandreweiss/terraform-azurerm-vnetpeering"

  left_vnet_resource_group_name  = azurerm_resource_group.ars-lab-r1.name
  left_vnet_name                 = azurerm_virtual_network.ars-spoke-vn.name
  right_vnet_resource_group_name = azurerm_resource_group.ars-lab-r1.name
  right_vnet_name                = azurerm_virtual_network.spoke-vn.name
  allow_forwarded_traffic        = true
  left_allow_gateway_transit     = true
  left_use_remote_gateways       = false
  right_allow_gateway_transit    = false
  right_use_remote_gateways      = true


  depends_on = [
    azurerm_virtual_network.ars-spoke-vn,
    azurerm_virtual_network.spoke-vn
    # module.ars_spoke_r1
  ]
}

# Peering from FW to spoke duplicate
# module "spoke-vn-fw-peering" {
#   source = "github.com/alexandreweiss/terraform-azurerm-vnetpeering"

#   left_vnet_resource_group_name  = azurerm_resource_group.ars-lab-r1.name
#   left_vnet_name                 = azurerm_virtual_network.fw-vn.name
#   right_vnet_resource_group_name = azurerm_resource_group.ars-lab-r1.name
#   right_vnet_name                = azurerm_virtual_network.spoke-vn.name
#   allow_forwarded_traffic        = true


#   depends_on = [
#     azurerm_virtual_network.ars-spoke-vn,
#     azurerm_virtual_network.spoke-vn
#   ]
# }

# Peering from Aviatrix Transit to FW (to keep) #4
module "fw-transit-vn-peering" {
  source = "github.com/alexandreweiss/terraform-azurerm-vnetpeering"

  left_vnet_resource_group_name  = azurerm_resource_group.ars-lab-r1.name
  left_vnet_name                 = azurerm_virtual_network.fw-vn.name
  right_vnet_resource_group_name = azurerm_resource_group.ars-lab-r1.name
  right_vnet_name                = module.azure_transit_ars.vpc.name
  allow_forwarded_traffic        = true

  depends_on = [
    azurerm_virtual_network.fw-vn,
    module.azure_transit_ars
  ]
}

# Peering from FW to Aviatrix ARS #5

module "fw-ars-vn-peering" {
  source = "github.com/alexandreweiss/terraform-azurerm-vnetpeering"

  left_vnet_resource_group_name  = azurerm_resource_group.ars-lab-r1.name
  left_vnet_name                 = azurerm_virtual_network.fw-vn.name
  right_vnet_resource_group_name = azurerm_resource_group.ars-lab-r1.name
  right_vnet_name                = azurerm_virtual_network.ars-vn.name
  allow_forwarded_traffic        = true
  left_allow_gateway_transit     = false
  left_use_remote_gateways       = true
  right_allow_gateway_transit    = true
  right_use_remote_gateways      = false


  depends_on = [
    azurerm_virtual_network.ars-vn,
    azurerm_virtual_network.fw-vn
  ]
}

# 6 ARS Spoke to FW
module "spoke-vn-fw-vn-peering" {
  source = "github.com/alexandreweiss/terraform-azurerm-vnetpeering"

  left_vnet_resource_group_name  = azurerm_resource_group.ars-lab-r1.name
  left_vnet_name                 = azurerm_virtual_network.ars-spoke-vn.name
  right_vnet_resource_group_name = azurerm_resource_group.ars-lab-r1.name
  right_vnet_name                = azurerm_virtual_network.fw-vn.name
  allow_forwarded_traffic        = true
  # left_allow_gateway_transit     = true
  # left_use_remote_gateways       = false
  # right_allow_gateway_transit    = false
  # right_use_remote_gateways      = true


  depends_on = [
    azurerm_virtual_network.fw-vn,
    azurerm_virtual_network.ars-spoke-vn
    # module.ars_spoke_r1
  ]
}
