variable "admin_password" {
  sensitive   = true
  type        = string
  description = "Admin password for admin user"
}

variable "site" {
  type        = string
  description = "Site identifier for VM creation (e.g., india, mumbai, singapore)"
  default     = "india"
}
