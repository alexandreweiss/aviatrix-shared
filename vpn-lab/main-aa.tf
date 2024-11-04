resource "azurerm_resource_group" "rg" {
  name     = "vpn-lab-rg-${var.workspace_key}"
  location = var.azure_r1_location
}

resource "azurerm_public_ip" "pip_0" {
  allocation_method   = "Static"
  location            = var.azure_r1_location
  name                = "vpn-gw-${var.azure_r1_location_short}-pip-0"
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  sku_tier            = "Regional"
}

resource "azurerm_public_ip" "pip_1" {
  allocation_method   = "Static"
  location            = var.azure_r1_location
  name                = "vpn-gw-${var.azure_r1_location_short}-pip-1"
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
  sku_tier            = "Regional"
}

resource "azurerm_virtual_network" "vnet" {
  address_space       = [var.vnet_address_space]
  location            = var.azure_r1_location
  name                = "vpn-lab-vn"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "gw-subnet" {
  address_prefixes     = [cidrsubnet(var.vnet_address_space, 3, 3)]
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_subnet" "vm-subnet" {
  address_prefixes     = [cidrsubnet(var.vnet_address_space, 4, 1)]
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

resource "azurerm_virtual_network_gateway" "vpn-gw" {
  name                = "vpn-gw"
  location            = var.azure_r1_location
  resource_group_name = azurerm_resource_group.rg.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = true
  enable_bgp    = true
  generation    = "Generation2"

  bgp_settings {
    peering_addresses {
      ip_configuration_name = "vnetGatewayConfig_0"
      apipa_addresses       = ["169.254.21.1", "169.254.21.9"]
    }
    peering_addresses {
      ip_configuration_name = "vnetGatewayConfig_1"
      apipa_addresses       = ["169.254.21.5", "169.254.21.13"]
    }
    asn = 65515
  }
  sku = "VpnGw2"

  ip_configuration {
    name                          = "vnetGatewayConfig_0"
    public_ip_address_id          = azurerm_public_ip.pip_0.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gw-subnet.id
  }

  ip_configuration {
    name                          = "vnetGatewayConfig_1"
    public_ip_address_id          = azurerm_public_ip.pip_1.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gw-subnet.id
  }
}

resource "azurerm_local_network_gateway" "lng0" {
  location            = var.azure_r1_location
  name                = "avx-0-lng"
  resource_group_name = azurerm_resource_group.rg.name
  gateway_address     = "20.61.236.53"
  bgp_settings {
    asn                 = 65007
    bgp_peering_address = "169.254.21.2"
  }
}

resource "azurerm_local_network_gateway" "lng1" {
  location            = var.azure_r1_location
  name                = "avx-1-lng"
  resource_group_name = azurerm_resource_group.rg.name
  gateway_address     = "108.142.33.72"
  bgp_settings {
    asn                 = 65007
    bgp_peering_address = "169.254.21.6"
  }
}

resource "azurerm_virtual_network_gateway_connection" "vpn-gw-conn-0" {
  type                       = "IPsec"
  location                   = var.azure_r1_location
  name                       = "vpn-gw-conn-0"
  resource_group_name        = azurerm_resource_group.rg.name
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn-gw.id
  local_network_gateway_id   = azurerm_local_network_gateway.lng0.id
  shared_key                 = var.ferme_psk
  connection_mode            = "ResponderOnly"
  enable_bgp                 = true
  custom_bgp_addresses {
    primary   = "169.254.21.1"
    secondary = "169.254.21.5"
  }
}

resource "azurerm_virtual_network_gateway_connection" "vpn-gw-conn-1" {
  type                       = "IPsec"
  location                   = var.azure_r1_location
  name                       = "vpn-gw-conn-1"
  resource_group_name        = azurerm_resource_group.rg.name
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vpn-gw.id
  local_network_gateway_id   = azurerm_local_network_gateway.lng1.id
  shared_key                 = var.ferme_psk
  connection_mode            = "ResponderOnly"
  enable_bgp                 = true
  custom_bgp_addresses {
    primary   = "169.254.21.9"
    secondary = "169.254.21.13"
  }
}

module "r1-vpn-vm" {
  source              = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
  environment         = "vpn"
  location            = var.azure_r1_location
  location_short      = var.azure_r1_location_short
  index_number        = 01
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.vm-subnet.id
  admin_ssh_key       = var.ssh_public_key
  depends_on = [
  ]
}

data "dns_a_record_set" "controller_ip" {
  host = var.controller_fqdn
}

data "tfe_outputs" "dataplane" {
  organization = "ananableu"
  workspace    = "aviatrix-shared"
}

//To be disabled when Edge is deployed on same public IP
resource "aviatrix_transit_external_device_conn" "azure_0" {
  vpc_id                    = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.vpc_id
  custom_algorithms         = true
  connection_name           = "Azure0"
  connection_type           = "bgp"
  tunnel_protocol           = "IPSEC"
  bgp_local_as_num          = "65007"
  bgp_remote_as_num         = "65515"
  remote_gateway_ip         = azurerm_public_ip.pip_0.ip_address
  local_tunnel_cidr         = "169.254.21.2/30,169.254.21.10/30"
  remote_tunnel_cidr        = "169.254.21.1/30,169.254.21.9/30"
  ha_enabled                = true
  backup_remote_gateway_ip  = azurerm_public_ip.pip_1.ip_address
  backup_bgp_remote_as_num  = "65515"
  backup_local_tunnel_cidr  = "169.254.21.6/30,169.254.21.14/30"
  backup_remote_tunnel_cidr = "169.254.21.5/30,169.254.21.13/30"
  pre_shared_key            = var.ferme_psk
  backup_pre_shared_key     = var.ferme_psk
  enable_edge_segmentation  = false
  phase_1_authentication    = "SHA-256"
  phase_1_dh_groups         = "2"
  phase_1_encryption        = "AES-256-CBC"
  phase_2_authentication    = "HMAC-SHA-256"
  phase_2_dh_groups         = "14"
  phase_2_encryption        = "AES-256-CBC"
  enable_ikev2              = true
  gw_name                   = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.gw_name
  depends_on                = [azurerm_virtual_network_gateway.vpn-gw]

  //phase1_remote_identifier = ["90.45.76.36"]
  // Use in conjunction with Active / Standby on transit to do traffic on a single tunnel
  //switch_to_ha_standby_gateway = true
}

# resource "aviatrix_transit_external_device_conn" "azure_1" {
#   vpc_id                   = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.vpc_id
#   custom_algorithms        = true
#   connection_name          = "Azure1"
#   connection_type          = "bgp"
#   tunnel_protocol          = "IPSEC"
#   bgp_local_as_num         = "65007"
#   bgp_remote_as_num        = "65515"
#   remote_gateway_ip        = "20.82.54.159"
#   local_tunnel_cidr        = "169.254.21.10/30,169.254.21.14/30"
#   remote_tunnel_cidr       = "169.254.21.9/30,169.254.21.13/30"
#   enable_edge_segmentation = false
#   pre_shared_key           = var.ferme_psk
#   phase_1_authentication   = "SHA-256"
#   phase_1_dh_groups        = "2"
#   phase_1_encryption       = "AES-256-CBC"
#   phase_2_authentication   = "HMAC-SHA-256"
#   phase_2_dh_groups        = "14"
#   phase_2_encryption       = "AES-256-CBC"
#   enable_ikev2             = true
#   gw_name                  = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.gw_name
#   //phase1_remote_identifier = ["90.45.76.36"]
#   // Use in conjunction with Active / Standby on transit to do traffic on a single tunnel
#   //switch_to_ha_standby_gateway = true
# }
