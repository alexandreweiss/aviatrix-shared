variable "admin_password" {
  sensitive   = true
  description = "Admin password"
}

variable "controller_fqdn" {
  description = "FQDN or IP of the Aviatrix Controller"
  sensitive   = true
}

variable "ferme_fqdn" {
  description = "FQDN of Ferme ISP"
  sensitive   = true
}

variable "ferme_psk" {
  description = "Pre shared key of Ferme tunnel"
  sensitive   = true
}

variable "cato_psk" {
  description = "Pre shared key of the Cato tunnels (set in the workspace, never in git)"
  type        = string
  sensitive   = true
}
