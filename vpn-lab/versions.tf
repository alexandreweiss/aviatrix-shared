terraform {
  cloud {
    organization = "ananableu"
    workspaces {
      // To deploy multiple VPN environment, setup the corresponding TF Workspace with key value and CIDR
      name = "aviatrix-shared-vpn-lab"
      //name = "aviatrix-shared-vpn-lab-199-5"
    }
  }
}
