# Firewall VNet
resource "azurerm_virtual_network" "firewall_vnet" {
  name                = "vnet-firewall"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "firewall_subnet" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.firewall_vnet.name
  address_prefixes     = ["10.0.1.0/26"]
}

resource "azurerm_subnet" "firewall_mgmt_subnet" {
  name                 = "AzureFirewallManagementSubnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.firewall_vnet.name
  address_prefixes     = ["10.0.2.0/26"]
}

# Public IP for Azure Firewall
resource "azurerm_public_ip" "firewall_pip" {
  name                = "pip-firewall"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Public IP for Azure Firewall Management
resource "azurerm_public_ip" "firewall_mgmt_pip" {
  name                = "pip-firewall-mgmt"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Azure Firewall Policy
resource "azurerm_firewall_policy" "main" {
  name                = "fw-policy-main"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
}

# Firewall Policy Rule Collection Group
resource "azurerm_firewall_policy_rule_collection_group" "main" {
  name               = "fw-policy-rcg"
  firewall_policy_id = azurerm_firewall_policy.main.id
  priority           = 500

  nat_rule_collection {
    name     = "dnat_rule_collection"
    priority = 300
    action   = "Dnat"

    rule {
      name                = "ssh_to_vm"
      protocols           = ["TCP"]
      source_addresses    = ["*"]
      destination_address = azurerm_public_ip.firewall_pip.ip_address
      destination_ports   = ["22"]
      translated_address  = "10.1.1.4" # VM private IP (adjust as needed)
      translated_port     = "22"
    }
  }

  application_rule_collection {
    name     = "app_rule_collection"
    priority = 500
    action   = "Allow"

    rule {
      name = "allow_web_traffic"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses  = ["10.1.0.0/16"]
      destination_fqdns = ["*"]
    }
  }
}

# Azure Firewall Basic SKU
resource "azurerm_firewall" "main" {
  name                = "fw-main"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Basic"
  firewall_policy_id  = azurerm_firewall_policy.main.id

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.firewall_subnet.id
    public_ip_address_id = azurerm_public_ip.firewall_pip.id
  }

  management_ip_configuration {
    name                 = "mgmt-configuration"
    subnet_id            = azurerm_subnet.firewall_mgmt_subnet.id
    public_ip_address_id = azurerm_public_ip.firewall_mgmt_pip.id
  }
}

# Data source for existing Log Analytics workspace
data "azurerm_log_analytics_workspace" "main" {
  name                = "we-loga-ws"
  resource_group_name = "we-loga-rg"
}

# Diagnostic setting for Azure Firewall
resource "azurerm_monitor_diagnostic_setting" "firewall_diagnostics" {
  name                       = "fw-diagnostics"
  target_resource_id         = azurerm_firewall.main.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "AzureFirewallApplicationRule"
  }

  enabled_log {
    category = "AzureFirewallNetworkRule"
  }

  enabled_log {
    category = "AzureFirewallDnsProxy"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
