variable "customer_name" {
  description = "Name of customer to be used in resources"
  default     = "contoso"
}

variable "application_1" {
  description = "Name of application 1"
  default     = "MyApp1"
}

variable "application_2" {
  description = "Name of application 2"
  default     = "MyApp2"
}

variable "application_3" {
  description = "Name of application 3"
  default     = "MyApp3"
}

variable "customer_website" {
  description = "FQDN of customer website"
  default     = "www.aviatrix.com"
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

variable "blackhole_internet" {
  default     = false
  description = "if true, internet traffic is blackholed. We first deploy with internet for container access then we blackhole before injecting AVX spokes"
}
