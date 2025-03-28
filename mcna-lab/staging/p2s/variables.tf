variable "customer_name" {
  description = "Name of customer to be used in resources"
  default     = "contoso"
}

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

variable "ssh_public_key" {
  sensitive   = true
  description = "SSH public key for VM administration"
}

variable "azure_account" {
  description = "CSP account onboarder on the controller"
}

variable "aws_account" {
  description = "CSP account onboarder on the controller"
}

variable "gcp_account" {
  description = "CSP account onboarder on the controller"
}

locals {
  controller = {
    controller_vnet_name           = "avx-cplane-frc-vn"
    controller_resource_group_name = "avx-cplane-we-rg"
  }
}

variable "oci_r1_location" {
  default     = "France Central"
  description = "region to deploy resources"
  type        = string
}

variable "oci_r1_location_short" {
  default     = "frc"
  description = "region to deploy resources"
  type        = string
}

variable "oci_account" {
  description = "CSP account onboarder on the controller"
}
