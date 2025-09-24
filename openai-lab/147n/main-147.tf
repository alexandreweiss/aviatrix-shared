# Create a resource group in Azure region R1 named "rg-oai-lab"
resource "azurerm_resource_group" "r1-rg" {
  name     = "rg-oai-${var.azure_r1_location_short}-lab"
  location = var.azure_r1_location
}

resource "azurerm_virtual_network" "azure-spoke-oai-r1" {
  address_space       = ["10.147.70.0/24"]
  location            = var.azure_r1_location
  name                = "azr-${var.azure_r1_location_short}-spoke-oai-vn"
  resource_group_name = azurerm_resource_group.r1-rg.name
}

# Create virtual network
resource "azurerm_subnet" "r1-azure-spoke-oai-gw-subnet" {
  address_prefixes     = ["10.147.70.0/28"]
  name                 = "avx-gw-subnet"
  resource_group_name  = azurerm_resource_group.r1-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-oai-r1.name
}

resource "azurerm_subnet" "r1-azure-spoke-oai-hagw-subnet" {
  address_prefixes     = ["10.147.70.16/28"]
  name                 = "avx-hagw-subnet"
  resource_group_name  = azurerm_resource_group.r1-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-oai-r1.name
}

resource "azurerm_subnet" "r1-azure-spoke-oai-vm-subnet" {
  address_prefixes     = ["10.147.70.32/28"]
  name                 = "vm-subnet"
  resource_group_name  = azurerm_resource_group.r1-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-oai-r1.name
}

resource "azurerm_subnet" "r1-azure-spoke-aoi-webapp-subnet" {
  address_prefixes     = ["10.147.70.64/27"]
  name                 = "webapp-subnet"
  resource_group_name  = azurerm_resource_group.r1-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-oai-r1.name
  delegation {
    name = "delegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "r1-azure-spoke-aoi-pe-subnet" {
  address_prefixes                  = ["10.147.70.96/28"]
  name                              = "pe-subnet"
  resource_group_name               = azurerm_resource_group.r1-rg.name
  virtual_network_name              = azurerm_virtual_network.azure-spoke-oai-r1.name
  private_endpoint_network_policies = "Enabled"

}

resource "azurerm_subnet" "r1-azure-spoke-aoi-dns-inbound-subnet" {
  address_prefixes     = ["10.147.70.112/28"]
  name                 = "dns-inbound-subnet"
  resource_group_name  = azurerm_resource_group.r1-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-oai-r1.name
  delegation {
    name = "Microsoft.Network/dnsResolvers"
    service_delegation {
      name    = "Microsoft.Network/dnsResolvers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

resource "azurerm_subnet" "r1-azure-spoke-aoi-dns-outbound-subnet" {
  address_prefixes     = ["10.147.70.128/28"]
  name                 = "dns-outbound-subnet"
  resource_group_name  = azurerm_resource_group.r1-rg.name
  virtual_network_name = azurerm_virtual_network.azure-spoke-oai-r1.name
  delegation {
    name = "Microsoft.Network/dnsResolvers"
    service_delegation {
      name    = "Microsoft.Network/dnsResolvers"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

# Create an OpenAI Service named "aviatrix-ignite" in Azure Region R1
resource "azurerm_cognitive_account" "aviatrix-ignite" {
  name                          = "aviatrix-ignite-147"
  location                      = var.azure_oai_location
  resource_group_name           = azurerm_resource_group.r1-rg.name
  kind                          = "OpenAI"
  sku_name                      = "S0"
  custom_subdomain_name         = "aviatrix-ignite-${var.azure_oai_location_short}-147"
  public_network_access_enabled = false
  identity {
    type = "SystemAssigned"
  }
}

#Create a model deployment named "aviatrix-ignite-deployment" in Azure Region R1 using gpt-4 model inside the "aviatrix-ignite" service
resource "azurerm_cognitive_deployment" "aviatrix" {
  cognitive_account_id = azurerm_cognitive_account.aviatrix-ignite.id
  name                 = "aviatrix-ignite-gpt-4-deployment"
  rai_policy_name      = "Microsoft.DefaultV2"
  model {
    format  = "OpenAI"
    name    = "gpt-4.1"
    version = "2025-04-14"
  }
  sku {
    name     = "GlobalStandard"
    capacity = 10
  }
  version_upgrade_option = "OnceCurrentVersionExpired"
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

# Create a private DNS A record for openai service in Azure Region R1 in the private DNS zone "privatelink.openai.azure.com"
resource "azurerm_private_dns_a_record" "oai-srv-dns" {
  name                = azurerm_cognitive_account.aviatrix-ignite.custom_subdomain_name
  zone_name           = azurerm_private_dns_zone.openai_private_dns_zone.name
  resource_group_name = azurerm_resource_group.r1-rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.oai-srv-pe.private_service_connection.0.private_ip_address]
}

# Create OpenAI search service named "aviatrix-ignite-search" in Azure Region R1 with system assigned identity enabled
resource "azurerm_search_service" "aviatrix-ignite-search" {
  location                   = var.azure_r1_location
  name                       = "aviatrix-ignite-search-147"
  resource_group_name        = azurerm_resource_group.r1-rg.name
  network_rule_bypass_option = "AzureServices"
  sku                        = "basic"
  identity {
    type = "SystemAssigned"
  }
  public_network_access_enabled = false
  local_authentication_enabled  = true
  authentication_failure_mode   = "http401WithBearerChallenge"
}

# Create private DNS zone from OPenAI search service in Azure Region R1
resource "azurerm_private_dns_zone" "openai_search_private_dns_zone" {
  name                = "privatelink.search.windows.net"
  resource_group_name = azurerm_resource_group.r1-rg.name
}

# link it to the virtual network "azr-${var.azure_r1_location_short}-spoke-oai-vn"
resource "azurerm_private_dns_zone_virtual_network_link" "openai_search_private_dns_zone_link" {
  name                  = "privatelink.search.windows.net"
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

# Create a private DNS A record for openai search service in Azure Region R1 in the private DNS zone "privatelink.search.azure.com"
resource "azurerm_private_dns_a_record" "oai-search-srv-dns" {
  name                = azurerm_search_service.aviatrix-ignite-search.name
  zone_name           = azurerm_private_dns_zone.openai_search_private_dns_zone.name
  resource_group_name = azurerm_resource_group.r1-rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.oai-search-srv-pe.private_service_connection.0.private_ip_address]
}

# Generate random number using values between 00000 and 99999
resource "random_integer" "random" {
  min = 0
  max = 99999
}

# Create storage account in Azure Region R1 with the name "${azure_r1_region_short}avxignitesa${random_integer.random.result}"
resource "azurerm_storage_account" "avx-ignite-sa" {
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  location                      = var.azure_r1_location
  name                          = "${var.azure_r1_location_short}avxignitesa${random_integer.random.result}"
  resource_group_name           = azurerm_resource_group.r1-rg.name
  public_network_access_enabled = false
}

# Create a container named "oai-data" in the storage account "avx-ignite-sa"
resource "azurerm_storage_container" "oai-data" {
  name                  = "oai-data"
  storage_account_id    = azurerm_storage_account.avx-ignite-sa.id
  container_access_type = "private"
}

# Create private DNS zone for the storage account in Azure Region R1
resource "azurerm_private_dns_zone" "avx-ignite-sa-private-dns-zone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.r1-rg.name
}

# link it to the virtual network "azr-${var.azure_r1_location_short}-spoke-oai-vn"
resource "azurerm_private_dns_zone_virtual_network_link" "avx-ignite-sa-private-dns-zone-link" {
  name                  = "privatelink.blob.core.windows.net"
  resource_group_name   = azurerm_resource_group.r1-rg.name
  private_dns_zone_name = azurerm_private_dns_zone.avx-ignite-sa-private-dns-zone.name
  virtual_network_id    = azurerm_virtual_network.azure-spoke-oai-r1.id
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

# Create a private DNS A record for the storage account in Azure Region R1 in the private DNS zone "privatelink.blob.core.windows.net"
resource "azurerm_private_dns_a_record" "avx-ignite-sa-dns" {
  name                = azurerm_storage_account.avx-ignite-sa.name
  zone_name           = azurerm_private_dns_zone.avx-ignite-sa-private-dns-zone.name
  resource_group_name = azurerm_resource_group.r1-rg.name
  ttl                 = 300
  records             = [azurerm_private_endpoint.avx-ignite-sa-pe.private_service_connection.0.private_ip_address]
}

# Create an Azure Private DNS resolver in Azure Region R1 with the name "azr-${var.azure_r1_location_short}-private-dns-resolver"
resource "azurerm_private_dns_resolver" "r1-private-dns-resolver" {
  location            = var.azure_r1_location
  name                = "azr-${var.azure_r1_location_short}-private-dns-resolver"
  resource_group_name = azurerm_resource_group.r1-rg.name
  virtual_network_id  = azurerm_virtual_network.azure-spoke-oai-r1.id
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "dns-inbound" {
  name                    = "dns-inbound"
  location                = var.azure_r1_location
  private_dns_resolver_id = azurerm_private_dns_resolver.r1-private-dns-resolver.id
  ip_configurations {
    private_ip_allocation_method = "Dynamic"
    subnet_id                    = azurerm_subnet.r1-azure-spoke-aoi-dns-inbound-subnet.id
  }
}

# resource "azurerm_private_dns_resolver_outbound_endpoint" "dns-outbound" {
#   name                    = "dns-outbound"
#   location                = var.azure_r1_location
#   subnet_id               = azurerm_subnet.r1-azure-spoke-aoi-dns-outbound-subnet.id
#   private_dns_resolver_id = azurerm_private_dns_resolver.r1-private-dns-resolver.id
# }

## Create role assignments

# Create a role assignment for the OpenAI search to access the storage account using its managed identity
resource "azurerm_role_assignment" "oai-search-sa-access" {
  principal_id         = azurerm_search_service.aviatrix-ignite-search.identity.0.principal_id
  role_definition_name = "Storage Blob Data Reader"
  scope                = azurerm_storage_account.avx-ignite-sa.id
}

# Create a role assignement for the OpenAI service to access the search service using its managed identity
resource "azurerm_role_assignment" "oai-srv-search-access-0" {
  principal_id         = azurerm_cognitive_account.aviatrix-ignite.identity.0.principal_id
  role_definition_name = "Search Service Contributor"
  scope                = azurerm_search_service.aviatrix-ignite-search.id
}

resource "azurerm_role_assignment" "oai-srv-search-access-1" {
  principal_id         = azurerm_cognitive_account.aviatrix-ignite.identity.0.principal_id
  role_definition_name = "Search Index Data Reader"
  scope                = azurerm_search_service.aviatrix-ignite-search.id
}
