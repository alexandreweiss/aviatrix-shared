variable "location" {
  default = "West Europe"
}

resource "azurerm_resource_group" "asg-lab-rg" {
  name = "asg-lab-rg"
  location = var.location
}

resource "azurerm_application_security_group" "asg-front" {
  name = "asg-front"
  location = var.location
  resource_group_name = azurerm_resource_group.asg-lab-rg.name
}

resource "azurerm_virtual_network" "asg-vn" {
  address_space = ["10.0.0.0/24"]
  location = var.location
  resource_group_name = azurerm_resource_group.asg-lab-rg.name
  name = "asg-vn"
}

resource "azurerm_subnet" "asg-vn-default" {
  address_prefixes = [ "10.0.0.0/28" ]
  name = "default"
  resource_group_name = azurerm_resource_group.asg-lab-rg.name
  virtual_network_name = azurerm_virtual_network.asg-vn.name
}

resource "azurerm_network_interface" "asg-nic" {
  name = "asg-nic"
  ip_configuration {
    name = "ipconfig1"
    subnet_id = azurerm_subnet.asg-vn-default.id
    private_ip_address_allocation = "Dynamic"
  }
  location = var.location
  resource_group_name = azurerm_resource_group.asg-lab-rg.name
}

resource "azurerm_network_interface_application_security_group_association" "asg-nic-asg-front" {
  application_security_group_id = azurerm_application_security_group.asg-front.id
  network_interface_id = azurerm_network_interface.asg-nic.id

}

module "vm" {
  source = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"

  resource_group_name = azurerm_resource_group.asg-lab-rg.name
  subnet_id = azurerm_subnet.asg-vn-default.id
}