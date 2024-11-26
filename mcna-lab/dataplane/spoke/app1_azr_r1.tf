resource "random_integer" "app1_example" {
  min = 10000
  max = 99999
}

resource "null_resource" "app1_always_run" {
  triggers = {
    timestamp = "${timestamp()}"
  }
}

output "app1_random_integer" {
  value = random_integer.app1_example.result
}

resource "azurerm_resource_group" "app1_vms_rg" {
  location = var.azure_r1_location
  name     = "app1-vms-rg"
}


resource "azurerm_storage_account" "app1_aci_sa" {
  name                     = "acisa${random_integer.app1_example.result}"
  resource_group_name      = azurerm_resource_group.app1_vms_rg.name
  location                 = var.azure_r1_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
}

resource "azurerm_storage_share" "app1_aci_share" {
  name                 = "aci-config"
  storage_account_name = azurerm_storage_account.app1_aci_sa.name
  quota                = 1
}

resource "local_file" "app1_config_yaml" {
  filename = "app1-config.yaml"
  content = templatefile("${path.module}/app1_azr_r1_config.tpl",
    { "customer_name"    = var.customer_name,
      "application_2_ip" = azurerm_container_group.app2_container_group.ip_address,
      "application_2"    = var.application_2,
      "application_1"    = var.application_1,
      "customer_website" = var.customer_website
    }
  )
}


resource "azurerm_storage_share_file" "app1_config_file" {
  name             = "config.yaml"
  content_type     = "text/yaml"
  source           = local_file.app1_config_yaml.filename
  storage_share_id = azurerm_storage_share.app1_aci_share.id
  lifecycle {
    replace_triggered_by = [null_resource.app1_always_run]
  }
}

resource "azurerm_container_group" "app1_container_group" {
  name                = "${var.application_1}-cg"
  resource_group_name = azurerm_resource_group.app1_vms_rg.name
  location            = var.azure_r1_location
  depends_on          = [azurerm_subnet.r1-azure-spoke-app1-aci-subnet, azurerm_storage_share_file.app1_config_file]

  container {
    name = "gatus"
    # image  = "docker.io/aweiss4876/gatus-aviatrix:latest"
    image  = "aviatrixacr.azurecr.io/aviatrix/gatus-aviatrix:latest"
    cpu    = "1"
    memory = "1"
    ports {
      port     = 8080
      protocol = "TCP"
    }
    volume {
      name                 = "config"
      share_name           = "aci-config"
      mount_path           = "/config"
      storage_account_key  = azurerm_storage_account.app1_aci_sa.primary_access_key
      storage_account_name = azurerm_storage_account.app1_aci_sa.name
    }
  }
  exposed_port = [{
    port     = 8080
    protocol = "TCP"
  }]
  ip_address_type = "Private"
  subnet_ids      = [azurerm_subnet.r1-azure-spoke-app1-aci-subnet.id]
  os_type         = "Linux"
}

resource "aviatrix_smart_group" "app1" {
  name = "${var.application_1}-app"
  selector {
    match_expressions {
      cidr = azurerm_subnet.r1-azure-spoke-app1-aci-subnet.address_prefixes[0]
    }
  }
}

resource "aviatrix_smart_group" "azr-MyApp1-sg" {
  name = "${var.application_1}-app-vnet"
  selector {
    match_expressions {
      type = "vpc"
      name = azurerm_virtual_network.azure-spoke-app1-r1.name
    }
  }
}


resource "aviatrix_smart_group" "azr-MyApp1-cidr-sg" {
  name = "${var.application_1}-app-cidr"
  selector {
    match_expressions {
      cidr = azurerm_virtual_network.azure-spoke-app1-r1.address_space[0]
    }
  }
}
