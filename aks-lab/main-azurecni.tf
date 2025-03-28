# Azure Resource Group Creation
resource "azurerm_resource_group" "aks-lab-rg" {
  count = var.aks_cluster_qty

  location = var.azure_r1_location
  name     = "aks-lab-${count.index}-rg"
}

# Azure Virtual Network Creation for AKS
resource "azurerm_virtual_network" "vnet" {
  count = var.aks_cluster_qty

  address_space       = [var.vnet_address_space[count.index].infra_cidr, var.vnet_address_space[count.index].pod_cidr]
  location            = var.azure_r1_location
  name                = "aks-lab-${count.index}-vn"
  resource_group_name = azurerm_resource_group.aks-lab-rg[count.index].name
}

# Azure Subnet Creation for AKS - Node

resource "azurerm_subnet" "node-subnet" {
  count = var.aks_cluster_qty

  address_prefixes     = [cidrsubnet(var.vnet_address_space[count.index].infra_cidr, 2, 0)]
  name                 = "node-subnet"
  resource_group_name  = azurerm_resource_group.aks-lab-rg[count.index].name
  virtual_network_name = azurerm_virtual_network.vnet[count.index].name
}

# Azure Subnet Creation for AKS - Gateway subnet for Aviatrix Spoke
resource "azurerm_subnet" "gw-subnet" {
  count = var.aks_cluster_qty

  address_prefixes     = [cidrsubnet(var.vnet_address_space[count.index].infra_cidr, 4, 8)]
  name                 = "gw-subnet"
  resource_group_name  = azurerm_resource_group.aks-lab-rg[count.index].name
  virtual_network_name = azurerm_virtual_network.vnet[count.index].name
}

# Azure Subnet Creation for AKS - PODs
resource "azurerm_subnet" "pod-subnet" {
  count = var.aks_cluster_qty

  address_prefixes     = [var.vnet_address_space[count.index].pod_cidr]
  name                 = "pod-subnet"
  resource_group_name  = azurerm_resource_group.aks-lab-rg[count.index].name
  virtual_network_name = azurerm_virtual_network.vnet[count.index].name

  lifecycle {
    ignore_changes = [delegation]
  }
}

# Azure Route Table Creation for AKS - POD Subnet
resource "azurerm_route_table" "pod-subnet-rt" {
  count = var.aks_cluster_qty

  location            = var.azure_r1_location
  name                = "azr-${var.azure_r1_location_short}-pod-subnet-${count.index}-rt"
  resource_group_name = azurerm_resource_group.aks-lab-rg[count.index].name
  route {
    address_prefix = "0.0.0.0/0"
    name           = "InternetRouteBlackHole"
    next_hop_type  = "None"
  }

  lifecycle {
    ignore_changes = [
      route,
    ]
  }
}

# Azure Subnet Route Table Association for AKS - POD Subnet
resource "azurerm_subnet_route_table_association" "pod-subnet-rt-assoc" {
  count = var.aks_cluster_qty

  route_table_id = azurerm_route_table.pod-subnet-rt[count.index].id
  subnet_id      = azurerm_subnet.pod-subnet[count.index].id
}


# resource "azurerm_subnet" "service-subnet" {
#   count = var.aks_cluster_qty

#   address_prefixes     = [cidrsubnet(var.vnet_address_space[0], 4, 9)]
#   name                 = "service-subnet"
#   resource_group_name  = azurerm_resource_group.aks-lab-rg[count.index].name
#   virtual_network_name = azurerm_virtual_network.vnet[count.index].name
# }

# # Azure Kubernetes Cluster Creation
resource "azurerm_kubernetes_cluster" "k8s" {
  count = var.aks_cluster_qty

  location            = var.azure_r1_location
  name                = "aks-clust-${count.index}"
  resource_group_name = azurerm_resource_group.aks-lab-rg[count.index].name
  dns_prefix          = "ananableu"


  identity {
    type = "SystemAssigned"
  }
  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_D2_v2"
    node_count = var.node_count
    # pod_subnet_id  = azurerm_subnet.pod-subnet[count.index].id
    # vnet_subnet_id = azurerm_subnet.node-subnet[count.index].id
  }
  linux_profile {
    admin_username = "admin-lab"
    ssh_key {
      # key_data = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
      key_data = var.ssh_public_key
    }
  }
  network_profile {
    #  network_plugin = "kubenet"
    network_plugin = "azure"
    #  outbound_type     = "userDefinedRouting"
    #  load_balancer_sku = "standard"
    # service_cidr      = var.internal_service_address_space
    # dns_service_ip    = cidrhost(var.internal_service_address_space, 10)
  }

  # depends_on = [
  #   module.azr_r1_spoke_aks
  # ]
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.k8s
  sensitive = true
}
