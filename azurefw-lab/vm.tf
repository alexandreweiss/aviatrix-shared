# Network Security Group for VM
resource "azurerm_network_security_group" "vm_nsg" {
  name                = "nsg-vm"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Public IP for VM
resource "azurerm_public_ip" "vm_pip" {
  name                = "pip-vm"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Dynamic"
}

# Network Interface for VM
resource "azurerm_network_interface" "vm_nic" {
  name                = "nic-vm"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_pip.id
  }
}

# Associate NSG to NIC
resource "azurerm_network_interface_security_group_association" "vm_nsg_association" {
  network_interface_id      = azurerm_network_interface.vm_nic.id
  network_security_group_id = azurerm_network_security_group.vm_nsg.id
}

# Ubuntu VM
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm-ubuntu"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = "Standard_B1s"
  admin_username      = "admin-lab"

  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]

  admin_ssh_key {
    username   = "admin-lab"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQBsUy8OllCkhpOU4FplN1b7ypawC/8QM++3gb9EbqZHCJnJdTNhk/0QZVvGsPvWeSazsShgX2TdEMMdDFscWDdAfnoB+hyjhFyWaOfKXFdzafib3HrO0rGUPqW42V6d0N2V5rh23ZFZGX5Bp75KEFnrFgGY1axCebvMvStGzXXffole1sCt0SKbvFptc/MT/ZVSqT0i0ugS0dVXsb4kuo4qnNRUAqvunljDL5oS3ZT7bQtjAvcw+IyYF6Ka9pGc4EuNaYZ2YuaxMyMOKYoMq4Qz8Qk5oF34ATGCPC0SdAgtAByNblbYeB6s+ueWUwSEcKOfIKjl9lxJasCRBRkjl7zp non-prod-test"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
