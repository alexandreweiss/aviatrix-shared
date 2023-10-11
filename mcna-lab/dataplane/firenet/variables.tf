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

variable "firewall_admin_username" {
  description = "Admin username for Firewall (usually requires a stronger one than just admin)"
}

variable "admin_password" {
  sensitive   = true
  description = "Admin password"
}

variable "controller_fqdn" {
  description = "FQDN or IP of the Aviatrix Controller"
  sensitive   = true
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

variable "storage_access_key" {
  description = "Storage access key for PA bootstrap"
}
