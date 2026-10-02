# VM VNet
resource "azurerm_virtual_network" "vm_vnet" {
  name                = "vnet-vm"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "vm_subnet" {
  name                 = "subnet-vm"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vm_vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

# VNet Peering - VM VNet to Firewall VNet
resource "azurerm_virtual_network_peering" "vm_to_firewall" {
  name                = "peer-vm-to-firewall"
  resource_group_name = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vm_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.firewall_vnet.id
}

# VNet Peering - Firewall VNet to VM VNet
resource "azurerm_virtual_network_peering" "firewall_to_vm" {
  name                = "peer-firewall-to-vm"
  resource_group_name = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.firewall_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.vm_vnet.id
}
