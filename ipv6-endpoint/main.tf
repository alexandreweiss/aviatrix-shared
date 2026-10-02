// APP1 SPOKE in R1

// Replace app1 by app2 as need be
// Replace application_1 by application_2 as need be
// Replace CIDR block as need be 10.10.2 for app1, 10.11.2 for app2 ...

resource "azurerm_resource_group" "azr-r1-endpoint-rg" {
  location = var.azure_r1_location
  name     = "azr-${var.azure_r1_location_short}-ipv6-endpoint-${var.application_1}-${var.customer_name}-rg"
}

resource "azurerm_virtual_network" "azure-endpoint-r1" {
  address_space       = ["10.42.4.0/24", "fd00:10:13::/48"]
  location            = var.azure_r1_location
  name                = "azr-${var.azure_r1_location_short}-ipv6-endpoint-${var.application_1}-vn"
  resource_group_name = azurerm_resource_group.azr-r1-endpoint-rg.name
}

resource "azurerm_subnet" "r1-azure-endpoint-vm-subnet" {
  address_prefixes     = ["10.42.4.0/28", "fd00:10:13::/64"]
  name                 = "avx-vm-subnet"
  resource_group_name  = azurerm_resource_group.azr-r1-endpoint-rg.name
  virtual_network_name = azurerm_virtual_network.azure-endpoint-r1.name
}

module "azr-endpoint-vm" {
  source      = "github.com/alexandreweiss/misc-tf-modules/azr-linux-vm"
  environment = var.application_1
  tags = {
    "application" = var.application_1
    "environment" = "ipv6-workload"
  }
  location              = var.azure_r1_location
  location_short        = var.azure_r1_location_short
  index_number          = 02
  resource_group_name   = azurerm_resource_group.azr-r1-endpoint-rg.name
  subnet_id             = azurerm_subnet.r1-azure-endpoint-vm-subnet.id
  ipv6_subnet_id        = azurerm_subnet.r1-azure-endpoint-vm-subnet.id
  admin_ssh_key         = var.ssh_public_key
  customer_name         = var.customer_name
  enable_ipv6           = true
  enable_ipv6_public_ip = true
  custom_data = base64encode(<<-EOF
    #cloud-config
    package_update: true
    package_upgrade: true
    packages:
      - nginx
    runcmd:
      - systemctl start nginx
      - systemctl enable nginx
      - ufw allow 'Nginx Full'
      - echo '<html><body><h1>Hello from IPv6 Endpoint!</h1><p>Nginx is running on $(hostname)</p></body></html>' > /var/www/html/index.html
    EOF
  )

  depends_on = [
  ]
}
