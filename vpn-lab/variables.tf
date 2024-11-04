variable "azure_r1_location" {
  default     = "West Europe"
  description = "region to deploy resources"
  type        = string
}

variable "azure_r1_location_short" {
  default     = "we"
  description = "region to deploy resources"
  type        = string
}

variable "ssh_public_key" {
  sensitive   = true
  description = "SSH public key for VM administration"
}

variable "workspace_key" {
  description = "ID of the workspace to be used in rg creation"
}

variable "vnet_address_space" {
}

variable "ferme_psk" {
  description = "Pre shared key of Ferme tunnel"
  sensitive   = true
}

variable "admin_username" {
  default     = "admin"
  description = "administrator username"
}

variable "admin_password" {
  sensitive   = true
  description = "Admin password"
}

variable "controller_fqdn" {
  description = "FQDN or IP of the Aviatrix Controller"
}

variable "azure_account" {
  description = "CSP account onboarder on the controller"
}
