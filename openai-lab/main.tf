# Create a resource group in Azure region R1 named "rg-oai-lab"
resource "azurerm_resource_group" "r1-rg" {
  name     = "rg-oai-lab"
  location = var.azure_r1_location
}

resource "azurerm_virtual_network" "azure-spoke-oai-r1" {
  address_space       = ["172.19.10.0/24"]
  location            = var.azure_r1_location
  name                = "azr-${var.azure_r1_location_short}-spoke-oai-vn"
  resource_group_name = azurerm_resource_group.r1-rg.name
}

# Create virtual network
resource "azurerm_subnet" "r1-azure-spoke-oai-gw-subnet" {
  address_prefixes     = ["172.19.10.0/28"]
  name                 = "avx-gw-subnet"
  resource_group_name  = azurerm_resource_group.r1-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-oai-r1.name
}

resource "azurerm_subnet" "r1-azure-spoke-oai-hagw-subnet" {
  address_prefixes     = ["172.19.10.16/28"]
  name                 = "avx-hagw-subnet"
  resource_group_name  = azurerm_resource_group.r1-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-oai-r1.name
}

resource "azurerm_subnet" "r1-azure-spoke-oai-vm-subnet" {
  address_prefixes     = ["172.19.10.32/28"]
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.r1-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-oai-r1.name
}

resource "azurerm_subnet" "r1-azure-spoke-aoi-webapp-subnet" {
  address_prefixes     = ["172.19.10.64/27"]
  name                 = "webapp-subnet"
  resource_group_name  = azurerm_resource_group.r1-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-oai-r1.name
}

resource "azurerm_subnet" "r1-azure-spoke-aoi-pe-subnet" {
  address_prefixes     = ["172.19.10.96/28"]
  name                 = "pe-subnet"
  resource_group_name  = azurerm_resource_group.r1-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-oai-r1.name
}

# Create an OpenAI Service named "aviatrix-ignite" in Azure Region R1
resource "azurerm_cognitive_account" "aviatrix-ignite" {
  name                          = "aviatrix-ignite"
  location                      = var.azure_r1_location
  resource_group_name           = azurerm_resource_group.r1-rg.name
  kind                          = "OpenAI"
  sku_name                      = "S0"
  custom_subdomain_name         = "aviatrix-ignite"
  public_network_access_enabled = false
  identity {
    type = "SystemAssigned"
  }
}

#Create a model deployment named "aviatrix-ignite-deployment" in Azure Region R1 using gpt-4 model inside the "aviatrix-ignite" service
resource "azurerm_cognitive_deployment" "aviatrix" {
  cognitive_account_id = azurerm_cognitive_account.aviatrix-ignite.id
  name                 = "aviatrix-ignite-gpt-4-deployment"
  model {
    format = "OpenAI"
    name   = "gpt-4"
  }
  sku {
    name = "Standard"
  }

}

resource "azurerm_private_dns_zone" "openai_private_dns_zone" {
  name                = "privatelink.openai.azure.com"
  resource_group_name = azurerm_resource_group.r1-rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "openai_private_dns_zone_link" {
  name                  = "privatelink.openai.azure.com"
  resource_group_name   = azurerm_resource_group.r1-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.openai_private_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.azure-spoke-oai-r1.id
}

# resource "azurerm_private_dns_a_record" "oai-srv-dns" {
#   name                = azurerm_cognitive_account.aviatrix-ignite.name
#   zone_name           = azurerm_private_dns_zone.openai_private_dns_zone.name
#   resource_group_name = azurerm_resource_group.r1-rg.name
#   ttl                 = 300
#   records             = [azurerm_private_endpoint.oai-srv-pe.private_service_connection.0.private_ip_address]
# }

resource "azurerm_private_endpoint" "oai-srv-pe" {
  location            = var.azure_r1_location
  name                = "${azurerm_cognitive_account.aviatrix-ignite.name}-pe"
  resource_group_name = azurerm_resource_group.r1-rg.name
  subnet_id           = azurerm_subnet.r1-azure-spoke-aoi-pe-subnet.id
  private_service_connection {
    is_manual_connection           = false
    name                           = "${azurerm_cognitive_account.aviatrix-ignite.name}-pe"
    private_connection_resource_id = azurerm_cognitive_account.aviatrix-ignite.id
    subresource_names              = ["account"]
  }
}

# Create OpenAI search service named "aviatrix-ignite-search" in Azure Region R1 with system assigned identity enabled
resource "azurerm_search_service" "aviatrix-ignite-search" {
  location            = var.azure_r1_location
  name                = "aviatrix-ignite-search"
  resource_group_name = azurerm_resource_group.r1-rg.name
  sku                 = "basic"
  identity {
    type = "SystemAssigned"
  }
}

# Create private DNS zone from OPenAI search service in Azure Region R1
resource "azurerm_private_dns_zone" "openai_search_private_dns_zone" {
  name                = "privatelink.search.azure.com"
  resource_group_name = azurerm_resource_group.r1-rg.name
}

# link it to the virtual network "azr-${var.azure_r1_location_short}-spoke-oai-vn"
resource "azurerm_private_dns_zone_virtual_network_link" "openai_search_private_dns_zone_link" {
  name                  = "privatelink.search.azure.com"
  resource_group_name   = azurerm_resource_group.r1-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.openai_search_private_dns_zone.name
  virtual_network_id    = azurerm_virtual_network.azure-spoke-oai-r1.id
}

# Create a private endpoint for the OpenAI search service in Azure Region R1 in the "pe-subnet" with the name "aviatrix-ignite-search-pe" registered in private dns zone "privatelink.search.azure.com"
resource "azurerm_private_endpoint" "oai-search-srv-pe" {
  location            = var.azure_r1_location
  name                = "${azurerm_search_service.aviatrix-ignite-search.name}-pe"
  resource_group_name = azurerm_resource_group.r1-rg.name
  subnet_id           = azurerm_subnet.r1-azure-spoke-aoi-pe-subnet.id
  private_service_connection {
    is_manual_connection           = false
    name                           = "${azurerm_search_service.aviatrix-ignite-search.name}-pe"
    private_connection_resource_id = azurerm_search_service.aviatrix-ignite-search.id
    subresource_names              = ["searchService"]
  }
}

# Generate random number using values between 00000 and 99999
resource "random_integer" "random" {
  min = 0
  max = 99999
}

# Create storage account in Azure Region R1 with the name "${azure_r1_region_short}avxignitesa${random_integer.random.result}"
resource "azurerm_storage_account" "avx-ignite-sa" {
  account_tier             = "Standard"
  account_replication_type = "LRS"
  location                 = var.azure_r1_location
  name                     = "${var.azure_r1_location_short}avxignitesa${random_integer.random.result}"
  resource_group_name      = azurerm_resource_group.r1-rg.name
}

# Create private DNS zone for the storage account in Azure Region R1
resource "azurerm_private_dns_zone" "avx-ignite-sa-private-dns-zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.r1-rg.name
}

# Create a private endpoint for that storage account in Azure Region R1 in the "pe-subnet" with the name "avx-ignite-sa-pe" registered in private dns zone "privatelink.blob.core.windows.net"
resource "azurerm_private_endpoint" "avx-ignite-sa-pe" {
  location            = var.azure_r1_location
  name                = "${azurerm_storage_account.avx-ignite-sa.name}-pe"
  resource_group_name = azurerm_resource_group.r1-rg.name
  subnet_id           = azurerm_subnet.r1-azure-spoke-aoi-pe-subnet.id
  private_service_connection {
    is_manual_connection           = false
    name                           = "${azurerm_storage_account.avx-ignite-sa.name}-pe"
    private_connection_resource_id = azurerm_storage_account.avx-ignite-sa.id
    subresource_names              = ["blob"]
  }
}
