module "azure_transit_we" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.3.1"

  cloud   = "azure"
  region  = var.azure_we_location
  cidr    = "10.10.0.0/23"
  account = local.accounts.azure_account
  enable_transit_firenet = true
  gw_name = "azr-we-transit"
  local_as_number = 65007
  enable_segmentation = true
  enable_advertise_transit_cidr = true
  //instance_size = "Standard_B2ms"
  
}

module "azure_transit_ne" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.3.1"

  cloud   = "azure"
  region  = var.azure_ne_location
  cidr    = "10.20.0.0/23"
  account = local.accounts.azure_account
  enable_transit_firenet = true
  gw_name = "azr-ne-transit"
  local_as_number = 65008
  enable_segmentation = false
  //instance_size = "Standard_B2ms"
}

module "gcp_transit_we" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.3.1"

  cloud   = "GCP"
  region  = var.gcp_we_location
  cidr    = "10.30.0.0/23"
  account = local.accounts.gcp_account
  gw_name = "gcp-we-transit"
  local_as_number = 65009
}

