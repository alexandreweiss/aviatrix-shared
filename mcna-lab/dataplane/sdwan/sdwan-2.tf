# Resource group creation to store SDWAN lab
resource "azurerm_resource_group" "azr-r1-spoke-sdwan-2-rg" {
  location = var.azure_r1_location
  name     = "azr-${var.azure_r1_location_short}-spoke-sdwan-2-rg"
}

# VNET creation containing SDWAN VMs (r1-sdwan-vm and r1-sdwan-vm-2) 
resource "azurerm_virtual_network" "azure-spoke-sdwan-2-r1" {
  address_space       = ["10.60.5.0/24"]
  location            = var.azure_r1_location
  name                = "azr-${var.azure_r1_location_short}-spoke-sdwan-2-vn"
  resource_group_name = azurerm_resource_group.azr-r1-spoke-sdwan-2-rg.name
}


resource "azurerm_subnet" "r1-azure-spoke-sdwan-2-gw-subnet" {
  address_prefixes     = ["10.60.5.0/28"]
  name                 = "avx-gw-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-sdwan-2-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-sdwan-2-r1.name
}

resource "azurerm_subnet" "r1-azure-spoke-sdwan-2-hagw-subnet" {
  address_prefixes     = ["10.60.5.16/28"]
  name                 = "avx-hagw-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-sdwan-2-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-sdwan-2-r1.name
}

resource "azurerm_subnet" "r1-azure-spoke-sdwan-2-vm-subnet" {
  address_prefixes     = ["10.60.5.32/28"]
  name                 = "avx-vm-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-sdwan-2-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-sdwan-2-r1.name
}

# VNET peering creation between VNET containing Aviatrix transit and VNET containing SDWAN headends
module "transit-sdwan-2-peering" {
  source = "github.com/alexandreweiss/terraform-azurerm-vnetpeering"

  left_vnet_resource_group_name  = data.tfe_outputs.dataplane.values.transit_we_rg
  left_vnet_name                 = "azr-we-transit"
  right_vnet_resource_group_name = azurerm_resource_group.azr-r1-spoke-sdwan-2-rg.name
  right_vnet_name                = azurerm_virtual_network.azure-spoke-sdwan-2-r1.name
  allow_forwarded_traffic        = true

  depends_on = [
    azurerm_virtual_network.azure-spoke-sdwan-2-r1
  ]
}

# SDWAN headend 1
module "r1-sdwan-2-vm" {
  source               = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
  environment          = "sdwan-2"
  location             = var.azure_r1_location
  location_short       = var.azure_r1_location_short
  index_number         = 01
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-sdwan-2-rg.name
  subnet_id            = azurerm_subnet.r1-azure-spoke-sdwan-2-gw-subnet.id
  admin_ssh_key        = var.ssh_public_key
  vm_size              = "Standard_B1ms"
  enable_ip_forwarding = true
  custom_data          = data.template_cloudinit_config.config.rendered
}

# SDWAN headend 2
module "r1-sdwan-2-vm-2" {
  source               = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
  environment          = "sdwan-2"
  location             = var.azure_r1_location
  location_short       = var.azure_r1_location_short
  index_number         = 02
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-sdwan-2-rg.name
  subnet_id            = azurerm_subnet.r1-azure-spoke-sdwan-2-hagw-subnet.id
  admin_ssh_key        = var.ssh_public_key
  vm_size              = "Standard_B1ms"
  enable_ip_forwarding = true
  custom_data          = data.template_cloudinit_config.config.rendered
}

// Route table for SD-WAN BGP peer : THIS IS VERY IMPORTANT to SEND TRAFFIC BACK TO AVIATRIX TRANSIT
resource "azurerm_route_table" "rt-sdwan-2-back-transit" {
  location            = var.azure_r1_location
  name                = "sdwan-2-back-to-transit"
  resource_group_name = azurerm_resource_group.azr-r1-spoke-sdwan-2-rg.name

  route {
    address_prefix         = "10.0.0.0/8"
    name                   = "10_0_0_0_8"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.bgp_lan_ip_list[1]
  }

  route {
    address_prefix         = "192.168.0.0/16"
    name                   = "192_168_0_0_16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.bgp_lan_ip_list[1]
  }

  route {
    address_prefix         = "172.16.0.0/12"
    name                   = "172_16_0_0_12"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.bgp_lan_ip_list[1]
  }
}

# Route table association with SDWAN subnet 1 for return traffic to Aviatrix transit
resource "azurerm_subnet_route_table_association" "sdwan-2-rt-assoc" {
  route_table_id = azurerm_route_table.rt-sdwan-2-back-transit.id
  subnet_id      = azurerm_subnet.r1-azure-spoke-sdwan-2-gw-subnet.id
}

resource "azurerm_route_table" "rt-sdwan-2-ha-back-transit" {
  location            = var.azure_r1_location
  name                = "sdwan-2-ha-back-to-transit"
  resource_group_name = azurerm_resource_group.azr-r1-spoke-sdwan-2-rg.name

  route {
    address_prefix         = "10.0.0.0/8"
    name                   = "10_0_0_0_8"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.ha_bgp_lan_ip_list[1]
  }

  route {
    address_prefix         = "192.168.0.0/16"
    name                   = "192_168_0_0_16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.ha_bgp_lan_ip_list[1]
  }

  route {
    address_prefix         = "172.16.0.0/12"
    name                   = "172_16_0_0_12"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.ha_bgp_lan_ip_list[1]
  }
}

# Route table association with SDWAN subnet 2 for return traffic to Aviatrix transit
resource "azurerm_subnet_route_table_association" "sdwan-2-ha-rt-assoc" {
  route_table_id = azurerm_route_table.rt-sdwan-2-ha-back-transit.id
  subnet_id      = azurerm_subnet.r1-azure-spoke-sdwan-2-hagw-subnet.id
}

# Peering betwenn SDWAN VNET and TEST VNET containing the Test VM
# Removed to peer with tiered-2
# module "transit-sdwan-2-tiered-peering" {
#   source = "github.com/alexandreweiss/terraform-azurerm-vnetpeering"

#   left_vnet_resource_group_name  = azurerm_resource_group.azr-r1-spoke-sdwan-2-rg.name
#   left_vnet_name                 = azurerm_virtual_network.azure-spoke-sdwan-2-r1.name
#   right_vnet_resource_group_name = azurerm_resource_group.azr-r1-spoke-sdwan-rg.name
#   right_vnet_name                = azurerm_virtual_network.azure-spoke-sdwan-tiered-r1.name
#   allow_forwarded_traffic        = true

#   depends_on = [
#     azurerm_virtual_network.azure-spoke-sdwan-2-r1,
#     azurerm_virtual_network.azure-spoke-sdwan-tiered-r1
#   ]
# }

// Tiered vnet creation to host test VMs as branche of SDWAN device
resource "azurerm_virtual_network" "azure-spoke-sdwan-tiered-2-r1" {
  address_space       = ["10.60.3.0/24"]
  location            = var.azure_r1_location
  name                = "azr-${var.azure_r1_location_short}-spoke-sdwan-tiered-2-vn"
  resource_group_name = azurerm_resource_group.azr-r1-spoke-sdwan-2-rg.name
}

resource "azurerm_subnet" "r1-azure-spoke-sdwan-tiered-2-vm-subnet" {
  address_prefixes     = ["10.60.3.16/28"]
  name                 = "avx-vm-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-spoke-sdwan-2-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-sdwan-tiered-2-r1.name
}

# Peering betwenn SDWAN VNET and TEST TIERED VNET 2 containing the Test VM
module "transit-sdwan-tiered-2-peering" {
  source = "github.com/alexandreweiss/terraform-azurerm-vnetpeering"

  left_vnet_resource_group_name  = azurerm_resource_group.azr-r1-spoke-sdwan-2-rg.name
  left_vnet_name                 = azurerm_virtual_network.azure-spoke-sdwan-2-r1.name
  right_vnet_resource_group_name = azurerm_resource_group.azr-r1-spoke-sdwan-2-rg.name
  right_vnet_name                = azurerm_virtual_network.azure-spoke-sdwan-tiered-2-r1.name
  allow_forwarded_traffic        = true

  depends_on = [
    azurerm_virtual_network.azure-spoke-sdwan-2-r1,
    azurerm_virtual_network.azure-spoke-sdwan-tiered-2-r1
  ]
}

// Tiered test VM
module "r1-sdwan-tiered-2-vm" {
  source              = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
  environment         = "sdwan-tiered-2"
  location            = var.azure_r1_location
  location_short      = var.azure_r1_location_short
  index_number        = 01
  resource_group_name = azurerm_resource_group.azr-r1-spoke-sdwan-2-rg.name
  subnet_id           = azurerm_subnet.r1-azure-spoke-sdwan-tiered-2-vm-subnet.id
  admin_ssh_key       = var.ssh_public_key
  vm_size             = "Standard_B1ms"
}

// Route table for tiered VM to send traffic to SDWAN headend
resource "azurerm_route_table" "rt-to-sdwan-2" {
  location            = var.azure_r1_location
  name                = "sdwan-tiered-2-vm"
  resource_group_name = azurerm_resource_group.azr-r1-spoke-sdwan-rg.name

  route {
    address_prefix         = "0.0.0.0/0"
    name                   = "toSdwan"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = module.r1-sdwan-2-vm.vm_private_ip
  }
}

# Route table association to TEST VM subnet
resource "azurerm_subnet_route_table_association" "tiered-2-vm-rt-assoc" {
  route_table_id = azurerm_route_table.rt-to-sdwan-2.id
  subnet_id      = azurerm_subnet.r1-azure-spoke-sdwan-tiered-2-vm-subnet.id
}

# This is the BGP over LAN connection creation on Aviatrix side
resource "aviatrix_spoke_external_device_conn" "transit-sdwan-2-bgp" {
  vpc_id                   = data.tfe_outputs.dataplane.values.transit_we.vpc.vpc_id
  connection_name          = "sdwan-2"
  gw_name                  = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.gw_name
  connection_type          = "bgp"
  tunnel_protocol          = "LAN"
  bgp_local_as_num         = "65007"
  bgp_remote_as_num        = "65000"
  remote_lan_ip            = "10.60.5.4"
  local_lan_ip             = var.transit_gw_eth4_bgp_ip
  remote_vpc_name          = "${azurerm_virtual_network.azure-spoke-sdwan-2-r1.name}:${azurerm_resource_group.azr-r1-spoke-sdwan-2-rg.name}:${data.azurerm_subscription.current.subscription_id}"
  backup_local_lan_ip      = var.transit_hagw_eth4_bgp_ip
  backup_remote_lan_ip     = "10.60.5.20"
  backup_bgp_remote_as_num = "65000"
  ha_enabled               = true
  depends_on               = [module.transit-sdwan-2-peering]
}
