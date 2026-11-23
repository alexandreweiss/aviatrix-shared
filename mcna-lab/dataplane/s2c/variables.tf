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

variable "cato_active_pops" {
  description = "Cato PoPs the transit connects to: primary (PoP 1) and/or secondary (PoP 2)"
  type        = list(string)
  default     = ["primary"]
}
