resource "azurerm_resource_group" "aks-lab-rg" {
  location = var.azure_r1_location
  name     = "aks-lab-rg"
}

resource "azurerm_kubernetes_cluster" "k8s" {
  location            = var.azure_r1_location
  name                = "aks-clust-0"
  resource_group_name = azurerm_resource_group.aks-lab-rg.name
  dns_prefix          = "ananableu"

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_D2_v2"
    node_count = var.node_count
  }
  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      //key_data = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
      key_data = var.ssh_public_key
    }
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}
