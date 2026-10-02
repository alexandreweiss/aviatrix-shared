resource "azurerm_bastion_host" "bastion" {
  name = "${local.bastion.bastion_name}"
  location = var.location
  resource_group_name = var.resource_group_name
  sku = "Basic"
  ip_configuration {
    name = "ipconfig1"
    subnet_id = var.subnet_id
    public_ip_address_id = azurerm_public_ip.bastion-pip.id
  }
}

resource "azurerm_public_ip" "bastion-pip" {
  location = var.location
  name = "${var.location_short}-bastion-pip"
  resource_group_name = azurerm_resource_group.bastion-rg.name
  sku = "Standard"
  sku_tier = "Regional"
  allocation_method = "Static"
}

resource "azurerm_resource_group" "bastion-rg" {
  name = var.resource_group_name
  location = var.location
}