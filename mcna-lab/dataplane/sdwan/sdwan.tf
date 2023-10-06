// Retrieve the transit
data "tfe_outputs" "dataplane" {
  organization = "ananableu"
  workspace    = "aviatrix-shared"
}

data "dns_a_record_set" "controller_ip" {
  host = var.controller_fqdn
}

data "template_file" "cloudconfig-sdwan" {
  template = file("${path.module}/cloud-init.tpl")

  vars = {
    transit_gw_bgp_ip   = var.transit_gw_bgp_ip,
    transit_hagw_bgp_ip = var.transit_hagw_bgp_ip
    asn_sdwan           = var.asn_sdwan
  }
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.cloudconfig-sdwan.rendered
  }
}

output "transit_we" {
  value     = data.tfe_outputs.dataplane.values.transit_we
  sensitive = true
}

resource "azurerm_resource_group" "azr-r1-spoke-sdwan-rg" {
  location = var.azure_r1_location
  name     = "azr-${var.azure_r1_location_short}-spoke-sdwan-rg"
}

resource "azurerm_virtual_network" "azure-spoke-sdwan-r1" {
  address_space       = ["10.60.1.0/24"]
  location            = var.azure_r1_location
  name                = "azr-${var.azure_r1_location_short}-spoke-sdwan-vn"
  resource_group_name = azurerm_resource_group.azr-r1-spoke-sdwan-rg.name
}


resource "azurerm_subnet" "r1-azure-spoke-sdwan-gw-subnet" {
  address_prefixes     = ["10.60.1.0/28"]
  name                 = "avx-gw-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-sdwan-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-sdwan-r1.name
}

resource "azurerm_subnet" "r1-azure-spoke-sdwan-hagw-subnet" {
  address_prefixes     = ["10.60.1.16/28"]
  name                 = "avx-hagw-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-sdwan-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-sdwan-r1.name
}

resource "azurerm_subnet" "r1-azure-spoke-sdwan-vm-subnet" {
  address_prefixes     = ["10.60.1.32/28"]
  name                 = "avx-vm-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-sdwan-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-sdwan-r1.name
}

module "transit-sdwan-peering" {
  source = "github.com/alexandreweiss/terraform-azurerm-vnetpeering"

  left_vnet_resource_group_name  = data.tfe_outputs.dataplane.values.transit_we_rg
  left_vnet_name                 = "azr-we-transit"
  right_vnet_resource_group_name = azurerm_resource_group.azr-r1-spoke-sdwan-rg.name
  right_vnet_name                = azurerm_virtual_network.azure-spoke-sdwan-r1.name
  allow_forwarded_traffic        = true

  depends_on = [
    azurerm_virtual_network.azure-spoke-sdwan-r1
  ]
}

module "r1-sdwan-vm" {
  source               = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
  environment          = "sdwan"
  location             = var.azure_r1_location
  location_short       = var.azure_r1_location_short
  index_number         = 01
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-sdwan-rg.name
  subnet_id            = azurerm_subnet.r1-azure-spoke-sdwan-gw-subnet.id
  admin_ssh_key        = var.ssh_public_key
  vm_size              = "Standard_B1ms"
  enable_ip_forwarding = true
  custom_data          = data.template_cloudinit_config.config.rendered
}

module "r1-sdwan-vm-2" {
  source               = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
  environment          = "sdwan"
  location             = var.azure_r1_location
  location_short       = var.azure_r1_location_short
  index_number         = 02
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-sdwan-rg.name
  subnet_id            = azurerm_subnet.r1-azure-spoke-sdwan-hagw-subnet.id
  admin_ssh_key        = var.ssh_public_key
  vm_size              = "Standard_B1ms"
  enable_ip_forwarding = true
  custom_data          = data.template_cloudinit_config.config.rendered
}

// Route table for SD-WAN BGP peer
resource "azurerm_route_table" "rt-sdwan-back-transit" {
  location            = var.azure_r1_location
  name                = "sdwan-back-to-transit"
  resource_group_name = azurerm_resource_group.azr-r1-spoke-sdwan-rg.name

  route {
    address_prefix         = "10.0.0.0/8"
    name                   = "10_0_0_0_8"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.bgp_lan_ip_list[0]
  }

  route {
    address_prefix         = "192.168.0.0/16"
    name                   = "192_168_0_0_16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.bgp_lan_ip_list[0]
  }

  route {
    address_prefix         = "172.16.0.0/12"
    name                   = "172_16_0_0_12"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.bgp_lan_ip_list[0]
  }
}

resource "azurerm_subnet_route_table_association" "sdwan-rt-assoc" {
  route_table_id = azurerm_route_table.rt-sdwan-back-transit.id
  subnet_id      = azurerm_subnet.r1-azure-spoke-sdwan-gw-subnet.id
}

resource "azurerm_route_table" "rt-sdwan-ha-back-transit" {
  location            = var.azure_r1_location
  name                = "sdwan-ha-back-to-transit"
  resource_group_name = azurerm_resource_group.azr-r1-spoke-sdwan-rg.name

  route {
    address_prefix         = "10.0.0.0/8"
    name                   = "10_0_0_0_8"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.ha_bgp_lan_ip_list[0]
  }

  route {
    address_prefix         = "192.168.0.0/16"
    name                   = "192_168_0_0_16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.ha_bgp_lan_ip_list[0]
  }

  route {
    address_prefix         = "172.16.0.0/12"
    name                   = "172_16_0_0_12"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.ha_bgp_lan_ip_list[0]
  }
}

resource "azurerm_subnet_route_table_association" "sdwan-ha-rt-assoc" {
  route_table_id = azurerm_route_table.rt-sdwan-ha-back-transit.id
  subnet_id      = azurerm_subnet.r1-azure-spoke-sdwan-hagw-subnet.id
}


// Tiered vnet creation
resource "azurerm_virtual_network" "azure-spoke-sdwan-tiered-r1" {
  address_space       = ["10.60.2.0/24"]
  location            = var.azure_r1_location
  name                = "azr-${var.azure_r1_location_short}-spoke-sdwan-tiered-vn"
  resource_group_name = azurerm_resource_group.azr-r1-spoke-sdwan-rg.name
}

resource "azurerm_subnet" "r1-azure-spoke-sdwan-tiered-vm-subnet" {
  address_prefixes     = ["10.60.2.16/28"]
  name                 = "avx-vm-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-sdwan-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-sdwan-tiered-r1.name
}

module "transit-sdwan-tiered-peering" {
  source = "github.com/alexandreweiss/terraform-azurerm-vnetpeering"

  left_vnet_resource_group_name  = azurerm_resource_group.azr-r1-spoke-sdwan-rg.name
  left_vnet_name                 = azurerm_virtual_network.azure-spoke-sdwan-r1.name
  right_vnet_resource_group_name = azurerm_resource_group.azr-r1-spoke-sdwan-rg.name
  right_vnet_name                = azurerm_virtual_network.azure-spoke-sdwan-tiered-r1.name
  allow_forwarded_traffic        = true

  depends_on = [
    azurerm_virtual_network.azure-spoke-sdwan-r1,
    azurerm_virtual_network.azure-spoke-sdwan-tiered-r1
  ]
}

// Tiered VM
module "r1-sdwan-tiered-vm" {
  source              = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
  environment         = "sdwan-tiered"
  location            = var.azure_r1_location
  location_short      = var.azure_r1_location_short
  index_number        = 01
  resource_group_name = azurerm_resource_group.azr-r1-spoke-sdwan-rg.name
  subnet_id           = azurerm_subnet.r1-azure-spoke-sdwan-tiered-vm-subnet.id
  admin_ssh_key       = var.ssh_public_key
  vm_size             = "Standard_B1ms"
}

// Route table for tiered VM
resource "azurerm_route_table" "rt-to-sdwan" {
  location            = var.azure_r1_location
  name                = "sdwan-tiered-vm"
  resource_group_name = azurerm_resource_group.azr-r1-spoke-sdwan-rg.name

  route {
    address_prefix         = "0.0.0.0/0"
    name                   = "toSdwan"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = module.r1-sdwan-vm.vm_private_ip
  }
}

resource "azurerm_subnet_route_table_association" "tiered-vm-rt-assoc" {
  route_table_id = azurerm_route_table.rt-to-sdwan.id
  subnet_id      = azurerm_subnet.r1-azure-spoke-sdwan-tiered-vm-subnet.id
}

//Create BGP o LAN on Transit to sdwan

data "azurerm_subscription" "current" {}

resource "aviatrix_spoke_external_device_conn" "transit-sdwan-bgp" {
  vpc_id            = data.tfe_outputs.dataplane.values.transit_we.vpc.vpc_id
  connection_name   = "sdwan"
  gw_name           = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.gw_name
  connection_type   = "bgp"
  tunnel_protocol   = "LAN"
  bgp_local_as_num  = "65007"
  bgp_remote_as_num = "65000"
  remote_lan_ip     = "10.60.1.4"
  # local_lan_ip             = "10.10.0.148"
  remote_vpc_name          = "${azurerm_virtual_network.azure-spoke-sdwan-r1.name}:${azurerm_resource_group.azr-r1-spoke-sdwan-rg.name}:${data.azurerm_subscription.current.subscription_id}"
  backup_local_lan_ip      = "10.10.0.156"
  backup_remote_lan_ip     = "10.60.1.20"
  backup_bgp_remote_as_num = "65000"
  ha_enabled               = true
  depends_on               = [module.transit-sdwan-peering]
}
