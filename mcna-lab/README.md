# Accept Aviatrix programmatic deployments
az vm image accept-terms --urn aviatrix-systems:aviatrix-copilot:avx-cplt-byol-01:1.5.1

# Require a terraform.tfvars file in dataplace directory with following values :
ferme_fqdn              = FQDN of an on-prem IPSec Device for on-prem connectivity

ferme_psk               = VPN Preshared key

ssh_public_key          = "ssh-rsa xxx" public key format to access linux VMs

admin_password          = Admin password for VMs

firewall_admin_password = Firenet/Firewall admin password

controller_ip           = Controller FQDN or IP to target deploy
