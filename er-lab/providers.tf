provider "azurerm" {
  features {

  }
}

provider "packetfabric" {
  token    = var.packet_fabric_api_key
}

terraform {
  required_providers {
    packetfabric = {
      source = "PacketFabric/packetfabric"
    }
  }
}
