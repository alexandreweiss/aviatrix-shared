module "framework" {
  source  = "terraform-aviatrix-modules/backbone/aviatrix"
  version = "v8.0.0"

  global_settings = {

    transit_accounts = {
      aws   = "aws-alweiss",
      azure = "azure-alweiss",
      gcp   = "gcp"
    }

    firenet_firewall_image = {
      aws   = "Palo Alto Networks VM-Series Next-Generation Firewall Bundle 1",
      azure = "Palo Alto Networks VM-Series Next-Generation Firewall Bundle 1"
    }

    transit_ha_gw = false

  }

  transit_firenet = {

    #Transit firenet in AWS, using default_firewall_image
    transit1a = {
      transit_cloud       = "gcp",
      transit_cidr        = "10.1.0.0/23",
      transit_region_name = "europe-west1",
      transit_asn         = 65101
      
    },
    #Transit in Azure
    transit2 = {
      transit_cloud       = "azure",
      transit_cidr        = "10.1.2.0/23",
      transit_region_name = "West Europe",
      transit_asn         = 65102,
    },
    transit2b = {
      transit_cloud       = "azure",
      transit_cidr        = "10.1.4.0/23",
      transit_region_name = "North Europe",
      transit_asn         = 65103,
    }
  }
}
