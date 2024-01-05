variable "admin_password" {
  sensitive   = true
  description = "Admin password"
}

variable "controller_fqdn" {
  description = "FQDN or IP of the Aviatrix Controller"
  sensitive   = true
}

variable "edge_lan_bgp_ip" {
  description = "Edge LAN interface IP"
  default     = "192.168.71.10"
}

variable "edge_ha_lan_bgp_ip" {
  description = "Edge LAN interface IP"
  default     = "192.168.71.11"
}

variable "edge_local_as_number" {
  description = "Edge local AS number"
  default     = "65170"
}

variable "edge_ha_local_as_number" {
  description = "Edge HA local AS number"
  default     = "65170"
}

variable "remote_lan_bgp_ip" {
  description = "Remote LAN interface IP"
  default     = "192.168.71.20"
}

variable "remote_as_number" {
  description = "Remote AS number"
  default     = "65171"
}

variable "remote_location_type" {
  description = "Type of the remote edge site to be included in the name of the gateway"
  default     = "Agence"
}

variable "remote_location" {
  description = "Location of remote edge site to be included in the name of the gateway"
  default     = "Paris"
}

variable "remote_location_lat" {
  description = "Latitude of location"
  default     = "50.3239"
}

variable "remote_location_lon" {
  description = "Longitude of location"
  default     = "1.4337"
}
