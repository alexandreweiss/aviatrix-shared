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
  default     = "10.72.0.5"
}

variable "edge_ha_lan_bgp_ip" {
  description = "Edge LAN interface IP"
  default     = "10.72.0.6"
}

variable "edge_local_as_number" {
  description = "Edge local AS number"
  default     = "65090"
}

variable "edge_ha_local_as_number" {
  description = "Edge HA local AS number"
  default     = "65090"
}

variable "remote_lan_bgp_ip" {
  description = "Remote LAN interface IP"
  default     = "10.72.0.6"
}

variable "remote_as_number" {
  description = "Remote AS number"
  default     = "65190"
}

variable "remote_location_type" {
  description = "Type of the remote edge site to be included in the name of the gateway"
  default     = "plant"
}

variable "remote_location" {
  description = "Location of remote edge site to be included in the name of the gateway"
  default     = "pinetops"
}

variable "remote_location_lat" {
  description = "Latitude of location"
  default     = "35.80272"
}

variable "remote_location_lon" {
  description = "Longitude of location"
  default     = "-77.63982"
}
