# Accept Aviatrix programmatic deployments
az vm image accept-terms --urn aviatrix-systems:aviatrix-copilot:avx-cplt-byol-01:1.5.1

# Require a terraform.tfvars file in dataplace directory with following values :
ferme_fqdn              = FQDN of an on-prem IPSec Device for on-prem connectivity

ferme_psk               = VPN Preshared key

ssh_public_key          = "ssh-rsa xxx" public key format to access linux VMs

admin_password          = Admin password for VMs

firewall_admin_password = Firenet/Firewall admin password

controller_ip           = Controller FQDN or IP to target deploy

# Those TF files uses a backend in Terraform Cloud to store state.

versions.tf contains that block of code that you would need to update or just remove to keep state local

`  cloud {
    organization = "ananableu"
    workspaces {
      name = "aviatrix-misc"
    }
  }`

# Prepare for a demo

## Variables

Update variables in shared TF workspace with customer_name, 3 applications' names
Update variables in edge-sm TF workspace with location_type and remote_location

destroy any edge
destroy any transit peering
destroy any spoke
destroy any p2s
terraform apply on transit first
terraform apply on transit peering
terraform apply on P2S
terraform apply on spoke