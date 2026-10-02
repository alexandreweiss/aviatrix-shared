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

variable "azure_r2_location" {
  default     = "North Europe"
  description = "region to deploy resources"
  type        = string
}

variable "azure_r2_location_short" {
  default     = "ne"
  description = "region to deploy resources"
  type        = string
}

variable "gcp_r1_location" {
  default     = "europe-west1"
  description = "region to deploy resources"
  type        = string
}

variable "gcp_r1_location_short" {
  default     = "we"
  description = "region to deploy resources"
  type        = string
}

variable "aws_r1_location" {
  default     = "eu-central-1"
  description = "region to deploy resources"
  type        = string
}

variable "aws_r1_location_short" {
  default     = "fra"
  description = "region to deploy resources"
  type        = string
}

variable "oci_r1_location" {
  default     = "eu-frankfurt-1"
  description = "region to deploy resources"
  type        = string
}

variable "oci_r1_location_short" {
  default     = "fra"
  description = "region to deploy resources"
  type        = string
}

variable "ferme_fqdn" {
  description = "FQDN of Ferme ISP"
}

variable "admin_username" {
  default     = "admin"
  description = "administrator username"
}

variable "admin_password" {
  sensitive   = true
  description = "Admin password"
}

variable "ssh_public_key" {
  description = "SSH public key for VM administration"
}

variable "controller_fqdn" {
  description = "FQDN or IP of the Aviatrix Controller"
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

variable "oci_account" {
  description = "CSP account onboarder on the controller"
}
