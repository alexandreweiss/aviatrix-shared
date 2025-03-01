// Tiered test VM
module "r1-spoke-vm" {
  source              = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
  environment         = "app-vm"
  location            = var.azure_r1_location
  location_short      = var.azure_r1_location_short
  index_number        = 01
  resource_group_name = azurerm_resource_group.ars-lab-r1.name
  subnet_id           = azurerm_subnet.spoke-vm-subnet.id
  admin_ssh_key       = var.ssh_public_key
  vm_size             = "Standard_B1ms"
}

// Route table for tiered VM to send traffic to SDWAN headend
resource "azurerm_route_table" "rt-to-fw" {
  location                      = var.azure_r1_location
  name                          = "fw-tiered-vm"
  resource_group_name           = azurerm_resource_group.ars-lab-r1.name
  bgp_route_propagation_enabled = false

  route {
    address_prefix         = "0.0.0.0/0"
    name                   = "toFw"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_lb.fw_lb.private_ip_address
  }
}

# Route table association to TEST VM subnet
resource "azurerm_subnet_route_table_association" "tiered-vm-rt-assoc" {
  route_table_id = azurerm_route_table.rt-to-fw.id
  subnet_id      = azurerm_subnet.spoke-vm-subnet.id
}
