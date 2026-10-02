resource "azurerm_resource_group" "rg" {
  location = var.r1_location
  name     = "vwan-lab-rg"

}

resource "azurerm_virtual_wan" "vwan" {
  location            = var.r1_location
  name                = "vwan-lab"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_virtual_hub" "r1-vhubs" {
  count               = length(local.data.r1_vhubs)
  location            = local.data.r1_vhubs[count.index].hub_location
  virtual_wan_id      = azurerm_virtual_wan.vwan.id
  name                = "${local.data.r1_vhubs[count.index].hub_location_short}-vhub-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  address_prefix      = local.data.r1_vhubs[count.index].hub_cidr
  sku                 = "Standard"
}

resource "azurerm_vpn_gateway" "r1-vpn-gw" {
  count               = length(local.data.r1_vpns)
  location            = local.data.r1_vhubs[count.index].hub_location
  name                = "${local.data.r1_vhubs[count.index].hub_location_short}-vpn-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_hub_id      = azurerm_virtual_hub.r1-vhubs[local.data.r1_vpns[count.index].hub_index].id
  bgp_settings {
    peer_weight = 100
    asn         = 65515
    instance_0_bgp_peering_address {
      custom_ips = ["169.254.21.1", "169.254.21.9"]
    }
    instance_1_bgp_peering_address {
      custom_ips = ["169.254.21.5", "169.254.21.13"]
    }
  }
  depends_on = [azurerm_virtual_hub.r1-vhubs]
}

resource "azurerm_virtual_hub_connection" "spoke-attachment" {
  count                     = length(local.data.r1_spoke_attachments)
  name                      = azurerm_virtual_network.spoke["${local.data.r1_spoke_attachments[count.index].spoke_index}"].name
  remote_virtual_network_id = azurerm_virtual_network.spoke["${local.data.r1_spoke_attachments[count.index].spoke_index}"].id
  virtual_hub_id            = azurerm_virtual_hub.r1-vhubs[local.data.r1_spoke_attachments[count.index].hub_index].id
}

data "tfe_outputs" "dataplane" {
  organization = "ananableu"
  workspace    = "aviatrix-shared"
}

resource "azurerm_virtual_hub_connection" "aviatrix-attachment" {
  count                     = length(local.data.r1_aviatrix_attachments)
  name                      = "avx-west-europe-transit"
  remote_virtual_network_id = data.tfe_outputs.dataplane.values.transit_we.vpc.azure_vnet_resource_id
  virtual_hub_id            = azurerm_virtual_hub.r1-vhubs[local.data.r1_aviatrix_attachments[count.index].vhub_index].id
}

resource "azurerm_virtual_hub_bgp_connection" "bgp-aviatrix" {
  count                         = length(local.data.r1_bgp_peers)
  name                          = local.data.r1_bgp_peers[count.index].name
  peer_asn                      = local.data.r1_bgp_peers[count.index].asn
  peer_ip                       = local.data.r1_bgp_peers[count.index].peer_ip
  virtual_hub_id                = azurerm_virtual_hub.r1-vhubs[local.data.r1_bgp_peers[count.index].hub_index].id
  virtual_network_connection_id = azurerm_virtual_hub_connection.aviatrix-attachment[local.data.r1_bgp_peers[count.index].attachment_index].id
  depends_on = [
    azurerm_virtual_hub_connection.aviatrix-attachment
  ]
}

resource "azurerm_virtual_network" "spoke" {
  count               = length(local.data.r1_spokes)
  address_space       = local.data.r1_spokes[count.index].spoke_address_spaces
  location            = local.data.r1_spokes[count.index].spoke_location
  name                = "azr-${local.data.r1_spokes[count.index].spoke_location_short}-spoke-${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "spoke_subnet" {
  count                = length(local.data.r1_subnets)
  address_prefixes     = local.data.r1_subnets[count.index].address_prefixes
  name                 = local.data.r1_subnets[count.index].subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.spoke["${local.data.r1_subnets[count.index].spoke_index}"].name
}

module "vms" {
  count  = length(local.data.r1_subnets)
  source = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"

  environment          = local.data.r1_spokes["${local.data.r1_subnets[count.index].spoke_index}"].spoke_environment
  location             = local.data.r1_spokes["${local.data.r1_subnets[count.index].spoke_index}"].spoke_location
  location_short       = local.data.r1_spokes["${local.data.r1_subnets[count.index].spoke_index}"].spoke_location_short
  index_number         = 01
  resource_group_name  = azurerm_resource_group.rg.name
  subnet_id            = azurerm_subnet.spoke_subnet[count.index].id
  admin_ssh_key        = var.ssh_public_key
  enable_ip_forwarding = true
}

resource "aviatrix_spoke_external_device_conn" "transit-vwan-bgp" {
  vpc_id            = data.tfe_outputs.dataplane.values.transit_we.vpc.vpc_id
  connection_name   = "to-vwan"
  gw_name           = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.gw_name
  connection_type   = "bgp"
  tunnel_protocol   = "LAN"
  bgp_local_as_num  = "65007"
  bgp_remote_as_num = "65515"
  remote_lan_ip     = "10.100.0.69"
  local_lan_ip      = "10.10.0.68"
  # remote_vpc_name          = "${azurerm_virtual_network.azure-spoke-sdwan-r1.name}:${azurerm_resource_group.azr-r1-spoke-sdwan-rg.name}:${data.azurerm_subscription.current.subscription_id}"
  remote_vpc_name          = "HV_we-vhub-0_0a58cf21-cd6f-4ddc-8ca9-5d3b9f574433:RG_we-vhub-0_63e69d9e-dd44-4864-b152-a900a77d5d78:dbea3fd0-ab34-4c99-90f6-9f2fcae78e1e"
  backup_local_lan_ip      = "10.10.0.76"
  backup_remote_lan_ip     = "10.100.0.68"
  backup_bgp_remote_as_num = "65515"
  ha_enabled               = true
  depends_on               = [azurerm_virtual_hub_connection.aviatrix-attachment]
}
