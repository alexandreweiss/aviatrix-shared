terraform {
  required_providers {
    aviatrix = {
      source  = "AviatrixSystems/aviatrix"
      version = ">= 3.1.0"
    }
  }
}

provider "aviatrix" {
  # Configuration can be provided via environment variables or here.
  # username = var.aviatrix_username
  # password = var.aviatrix_password
  # controller_ip = var.aviatrix_controller_ip
}

# Data source to retrieve account information
data "aviatrix_account" "example" {
  account_name = "default" # Change to your account name if needed
}

output "aviatrix_account" {
  value = data.aviatrix_account.example
}
