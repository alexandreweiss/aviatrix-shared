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

variable "admin_password" {
  sensitive   = true
  description = "Admin password"
}

variable "controller_fqdn" {
  description = "FQDN or IP of the Aviatrix Controller"
  sensitive   = true
}
