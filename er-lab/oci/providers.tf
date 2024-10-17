provider "azurerm" {
  features {

  }
}

provider "oci" {
  region       = "eu-frankfurt-1"
  alias        = "value"
  tenancy_ocid = var.oci_tenant_id
  user_ocid    = var.oci_user_id
  private_key  = var.oci_private_key
}

terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "6.12.0"
    }
  }
}
