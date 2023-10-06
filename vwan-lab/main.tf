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

resource "azurerm_virtual_hub_connection" "spoke-attachment" {
  count                     = length(local.data.r1_spoke_attachments)
  name                      = azurerm_virtual_network.spoke["${local.data.r1_spoke_attachments[count.index].spoke_index}"].name
  remote_virtual_network_id = azurerm_virtual_network.spoke["${local.data.r1_spoke_attachments[count.index].spoke_index}"].id
  virtual_hub_id            = azurerm_virtual_hub.r1-vhubs[local.data.r1_spoke_attachments[count.index].hub_index].id
}

resource "azurerm_virtual_hub_connection" "aviatrix-attachment" {
  count                     = length(local.data.r1_aviatrix_attachments)
  name                      = "avx-west-europe-transit"
  remote_virtual_network_id = "/subscriptions/cc67e95e-9baa-4ef4-bfac-a33a19ef2232/resourceGroups/azr-transit-we-0-rg/providers/Microsoft.Network/virtualNetworks/azr-we-transit"
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
    azurerm_virtual_hub_connection.spoke-attachment
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

  environment         = local.data.r1_spokes["${local.data.r1_subnets[count.index].spoke_index}"].spoke_environment
  location            = local.data.r1_spokes["${local.data.r1_subnets[count.index].spoke_index}"].spoke_location
  location_short      = local.data.r1_spokes["${local.data.r1_subnets[count.index].spoke_index}"].spoke_location_short
  index_number        = 01
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.spoke_subnet[count.index].id
  admin_ssh_key       = var.ssh_public_key
}
