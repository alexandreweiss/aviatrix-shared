variable "admin_password" {
  sensitive   = true
  description = "Admin password"
}

variable "controller_ip" {
  description = "FQDN or IP of the Aviatrix Controller"
  sensitive   = true
}

variable "ferme_fqdn" {
  description = "FQDN of Ferme ISP"
  sensitive   = true
}

variable "neo_devices" {
  description = "A list of devices to onboard"
  default = {
    "device0" = {
      "name"           = "neo-ferme"
      "serial_number"  = "VMware-56 4d f0 d5 c0 a6 59 d1-bd 28 12 3f fe 7f a6 f0",
      "hardware_model" = "ESXI-VM-2-WAN"
    }
    "device1" = {
      "name"           = "neo-studio"
      "serial_number"  = "26b2e4a4-eb44-4712-9c69-8095a4394d44",
      "hardware_model" = "ESXI-VM-2-WAN"
    }
  }
}

variable "neo_edges" {
  description = "A list of devices to onboard"
  default = {
    # "edge0" = {
    #   "gw_name"         = "edge-ferme"
    #   "site_id"         = "ferme",
    #   "gw_size"         = "small"
    #   "wan_ip"          = "192.168.60.160/24"
    #   "wan_gw_ip"       = "192.168.60.1"
    #   "lan_ip"          = "192.168.61.1/24"
    #   "local_as_number" = 65061
    #   "neo_device"      = "device0"
    # }
    # "edge1" = {
    #   "gw_name"         = "edge-studio"
    #   "site_id"         = "studio",
    #   "gw_size"         = "small"
    #   "wan_ip"          = "192.168.71.70/24"
    #   "wan_gw_ip"       = "192.168.71.1"
    #   "lan_ip"          = "192.168.80.1/24"
    #   "local_as_number" = 65080
    #   "neo_device"      = "device1"
    # }
  }
}

locals {
  accounts = {
    csp_account = "edgePlatform-0"
  }

  data = yamldecode(file("${path.module}/configuration.yaml"))

  devices_map = {
    for device in local.data.devices :
    device.name => {
      name           = device.name
      serial_number  = device.serial_number
      hardware_model = device.hardware_model
    }
  }

  edges_map = {
    for edge in local.data.edges :
    edge.name => {
      name            = edge.name
      gw_name         = edge.gw_name
      site_id         = edge.site_id,
      gw_size         = edge.gw_size
      wan_ip          = edge.wan_ip
      wan_gw_ip       = edge.wan_gw_ip
      lan_ip          = edge.lan_ip
      local_as_number = edge.local_as_number
      neo_device      = edge.neo_device
    }
  }
}
