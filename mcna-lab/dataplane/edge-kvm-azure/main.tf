provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-edge-kvm-${terraform.workspace}"
  location = "Central India"

  tags = {
    Environment = "Lab"
    Purpose     = "Aviatrix Edge KVM"
    CreatedBy   = "Terraform"
  }
}

# # Random suffix for unique naming
# resource "random_string" "suffix" {
#   length  = 3
#   special = false
#   upper   = false
#   lower   = false
#   numeric = true
# }

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-edge-kvm-${terraform.workspace}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = azurerm_resource_group.main.tags
}

# Subnet
resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Network Security Group and rules
resource "azurerm_network_security_group" "main" {
  name                = "nsg-edge-kvm-${terraform.workspace}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # SSH access
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

  # Cockpit web interface
  security_rule {
    name                       = "Cockpit"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9090"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = azurerm_resource_group.main.tags
}

# Public IP
resource "azurerm_public_ip" "main" {
  name                = "pip-edge-kvm-${terraform.workspace}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "kvm-lab-${terraform.workspace}"

  tags = azurerm_resource_group.main.tags
}

# Storage Account
resource "azurerm_storage_account" "main" {
  name                     = "edgekvmsa${terraform.workspace}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = azurerm_resource_group.main.tags
}

# File Share
resource "azurerm_storage_share" "main" {
  name                 = "edge-isos"
  storage_account_name = azurerm_storage_account.main.name
  quota                = 50
}

# Network Interface
resource "azurerm_network_interface" "main" {
  name                = "nic-edge-kvm-${terraform.workspace}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }

  tags = azurerm_resource_group.main.tags
}

# Associate Network Security Group to Network Interface
resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Generate SSH key pair
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Store private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.module}/ssh-key-${terraform.workspace}.pem"
  file_permission = "0600"
}

# Create configuration file for scripts
locals {
  workspace_id = tonumber(terraform.workspace)
  config_content = templatefile("${path.module}/config.env.tpl", {
    workspace_id         = local.workspace_id
    admin_password       = var.admin_password
    storage_account_name = azurerm_storage_account.main.name
    storage_account_key  = azurerm_storage_account.main.primary_access_key
    site                 = var.site
  })
}

# Upload configuration and scripts to storage account
resource "azurerm_storage_blob" "config" {
  name                   = "config.env"
  storage_account_name   = azurerm_storage_account.main.name
  storage_container_name = azurerm_storage_container.scripts.name
  type                   = "Block"
  source_content         = local.config_content
}

resource "azurerm_storage_container" "scripts" {
  name                  = "scripts"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "blob"
}

# Upload all script files
resource "azurerm_storage_blob" "scripts" {
  for_each               = fileset("${path.module}/scripts", "*.sh")
  name                   = each.value
  storage_account_name   = azurerm_storage_account.main.name
  storage_container_name = azurerm_storage_container.scripts.name
  type                   = "Block"
  source                 = "${path.module}/scripts/${each.value}"
}

# Simple cloud-init that downloads and runs scripts
data "local_file" "cloud_init" {
  filename = "${path.module}/cloud-init-standalone.yaml"
}

# Managed disk for /virtu mount point
resource "azurerm_managed_disk" "data" {
  name                 = "disk-data-${terraform.workspace}"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  storage_account_type = "Premium_LRS"
  create_option        = "Empty"
  disk_size_gb         = 100

  tags = azurerm_resource_group.main.tags
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "main" {
  name                = "vm-edge-kvm-${terraform.workspace}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = "Standard_D2as_v6"
  admin_username      = "admin-lab"

  # Disable password authentication
  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  admin_ssh_key {
    username   = "admin-lab"
    public_key = tls_private_key.ssh.public_key_openssh
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Cloud-init configuration
  custom_data = base64encode(templatefile("${path.module}/cloud-init-standalone.yaml", {
    storage_account_name = azurerm_storage_account.main.name
    storage_account_key  = azurerm_storage_account.main.primary_access_key
    admin_password       = var.admin_password
  }))

  # Enable boot diagnostics
  boot_diagnostics {
    storage_account_uri = null
  }

  tags = merge(azurerm_resource_group.main.tags, {
    Name = "Edge KVM Host"
  })
}

# Attach data disk to VM
resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  managed_disk_id    = azurerm_managed_disk.data.id
  virtual_machine_id = azurerm_linux_virtual_machine.main.id
  lun                = "0"
  caching            = "ReadWrite"
}
