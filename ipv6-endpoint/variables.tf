variable "customer_name" {
  description = "Name of customer to be used in resources"
  default     = "contoso"
}

variable "application_1" {
  description = "Name of application 1"
  default     = "MyApp1"
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

variable "ssh_public_key" {
  sensitive   = true
  description = "SSH public key for VM administration"
}
