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

locals {
  accounts = {
    azure_account = "azure-alweiss"
    aws_account   = "aws-alweiss"
    gcp_account   = "gcp-alweiss"
  }
}
