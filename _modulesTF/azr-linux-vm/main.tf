resource "azurerm_network_interface" "nic" {
  name                = local.vm.nic_name
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                  = local.vm.vm_name
  location              = var.location
  resource_group_name   = var.resource_group_name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = var.vm_size

  os_disk {
    name                 = "${local.vm.vm_name}-os-disk"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }

  computer_name                   = local.vm.vm_name
  admin_username                  = "admin-lab"
  disable_password_authentication = true

  admin_ssh_key {
    username   = "admin-lab"
    public_key = var.admin_ssh_key
  }
  tags = {
    "environment" = var.environment
  }
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "shutdown_vm" {
  daily_recurrence_time = "2100"
  timezone = "Romance Standard Time"
  location = var.location
  virtual_machine_id = azurerm_linux_virtual_machine.vm.id
  notification_settings {
    enabled = false
  }
}