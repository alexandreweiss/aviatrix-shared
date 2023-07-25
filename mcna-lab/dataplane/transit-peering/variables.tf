variable "admin_password" {
  sensitive   = true
  description = "Admin password"
}

variable "controller_fqdn" {
  description = "FQDN or IP of the Aviatrix Controller"
  sensitive   = true
}

locals {
  accounts = {
    azure_account = "azure-alweiss"
    aws_account   = "aws-alweiss"
    gcp_account   = "gcp-alweiss"
  }
}
