resource "random_integer" "app2_example" {
  min = 10000
  max = 99999
}

resource "null_resource" "app2_always_run" {
  triggers = {
    timestamp = "${timestamp()}"
  }
}

output "app_2_random_integer" {
  value = random_integer.app2_example.result
}

resource "azurerm_resource_group" "app2_vms_rg" {
  location = var.azure_r1_location
  name     = "app2-vms-rg"
}


resource "azurerm_storage_account" "app2_aci_sa" {
  name                     = "acisa${random_integer.app2_example.result}"
  resource_group_name      = azurerm_resource_group.app2_vms_rg.name
  location                 = var.azure_r1_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
}

resource "azurerm_storage_share" "app2_aci_share" {
  name                 = "aci-config"
  storage_account_name = azurerm_storage_account.app2_aci_sa.name
  quota                = 1
}

resource "local_file" "app2_config_yaml" {
  filename = "app2-config.yaml"
  content = templatefile("${path.module}/app2_azr_r1_config.tpl",
    { "customer_name"    = var.customer_name,
      "application_2"    = var.application_2,
      "customer_website" = var.customer_website
    }
  )
}

resource "azurerm_storage_share_file" "app2_config_file" {
  name             = "config.yaml"
  content_type     = "text/yaml"
  source           = local_file.app2_config_yaml.filename
  storage_share_id = azurerm_storage_share.app2_aci_share.id
  lifecycle {
    replace_triggered_by = [null_resource.app2_always_run]
  }
}

resource "azurerm_container_group" "app2_container_group" {
  name                = "${var.application_2}-cg"
  resource_group_name = azurerm_resource_group.app2_vms_rg.name
  location            = var.azure_r1_location
  depends_on          = [azurerm_subnet.r1-azure-spoke-app2-aci-subnet, azurerm_storage_share_file.app2_config_file]

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
      storage_account_key  = azurerm_storage_account.app2_aci_sa.primary_access_key
      storage_account_name = azurerm_storage_account.app2_aci_sa.name
    }
  }
  exposed_port = [{
    port     = 8080
    protocol = "TCP"
  }]
  ip_address_type = "Private"
  subnet_ids      = [azurerm_subnet.r1-azure-spoke-app2-aci-subnet.id]
  os_type         = "Linux"
}

# COMMENT OUT IF AWS IS NOT DEPLOYED
# resource "aviatrix_smart_group" "app2" {
#   name = "${var.application_2}-app"
#   selector {
#     match_expressions {
#       cidr = azurerm_subnet.r1-azure-spoke-app2-aci-subnet.address_prefixes[0]
#     }
#     match_expressions {
#       cidr = aws_subnet.this["front-a"].cidr_block
#     }
#   }
# }

resource "aviatrix_smart_group" "azr-MyApp2-sg" {
  name = "yes${var.application_2}-app-vnet"
  selector {
    match_expressions {
      type = "vpc"
      name = azurerm_virtual_network.azure-spoke-app2-r1.name
    }
  }
}

# resource "aviatrix_smart_group" "azr-MyApp2-cidr-sg" {
#   name = "yes${var.application_2}-app-cidr"
#   selector {
#     match_expressions {
#       cidr = azurerm_virtual_network.azure-spoke-app2-r1.address_space[0]
#     }
#   }
# }

resource "aviatrix_web_group" "allowed_domains" {
  name = "allowed-domains"
  selector {
    match_expressions {
      snifilter = var.customer_website
    }
  }
}

resource "aviatrix_web_group" "allowed_urls" {
  name = "allowed-urls"
  selector {
    match_expressions {
      urlfilter = "https://github.com/AviatrixSystems"
    }
  }
}
