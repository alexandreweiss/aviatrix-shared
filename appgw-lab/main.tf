resource "azurerm_resource_group" "rg" {
  name     = "appgw-lab"
  location = "France Central"
}

resource "azurerm_virtual_network" "vn" {
  name                = "vn-vnet"
  address_space       = ["10.123.122.0/23"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "appgw_subnet" {
  name                 = "appgw-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = ["10.123.122.0/24"]
}

resource "azurerm_subnet" "gw_subnet" {
  name                 = "gw-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = ["10.123.123.0/28"]
}

resource "azurerm_subnet" "hagw_subnet" {
  name                 = "hagw-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = ["10.123.123.16/28"]
}

resource "azurerm_public_ip" "pip" {
  name                = "appgw-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

resource "azurerm_application_gateway" "appgw" {
  name                = "appgw"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-gateway-ip-configuration"
    subnet_id = azurerm_subnet.gw_subnet.id
  }

  frontend_port {
    name = "frontendPort"
    port = 443
  }


  frontend_port {
    name = "frontendPort80"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "appgw-frontend-ip-configuration"
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  ssl_certificate {
    name     = "appgw-cert"
    data     = filebase64("lbusupport-1.pfx")
    password = "poshacme"
  }

  backend_address_pool {
    name         = "appgw-backend-address-pool"
    ip_addresses = ["10.10.4.132"]
  }

  backend_http_settings {
    name                                = "appgw-backend-http-settings"
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 20
    pick_host_name_from_backend_address = false
    host_name                           = "lbusupport.ananableu.fr"
    probe_name                          = "nginx-probe"
  }

  http_listener {
    name                           = "appgw-https-listener"
    frontend_ip_configuration_name = "appgw-frontend-ip-configuration"
    frontend_port_name             = "frontendPort"
    protocol                       = "Https"
    ssl_certificate_name           = "appgw-cert"
  }

  http_listener {
    name                           = "appgw-http-listener"
    frontend_ip_configuration_name = "appgw-frontend-ip-configuration"
    frontend_port_name             = "frontendPort80"
    protocol                       = "Http"
    # ssl_certificate_name           = "appgw-cert"
  }

  request_routing_rule {
    name                       = "appgw-request-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "appgw-https-listener"
    backend_address_pool_name  = "appgw-backend-address-pool"
    backend_http_settings_name = "appgw-backend-http-settings"
    priority                   = 10
  }

  request_routing_rule {
    name                       = "appgw-request-routing-rule-http"
    rule_type                  = "Basic"
    http_listener_name         = "appgw-http-listener"
    backend_address_pool_name  = "appgw-backend-address-pool"
    backend_http_settings_name = "appgw-backend-http-settings"
    priority                   = 20
  }

  probe {
    name                                      = "nginx-probe"
    protocol                                  = "Https"
    interval                                  = 1
    timeout                                   = 120
    unhealthy_threshold                       = 1
    pick_host_name_from_backend_http_settings = true
    # host                                      = "10.10.4.132"
    match {
      status_code = ["200-404"]
    }
    path = "/"
  }
}
