module "basic" {
  source            = "github.com/aviatrix/terraform-aviatrix-aws-controlplane?ref=dev"
  incoming_ssl_cidr = ["81.49.43.155/32"]
  admin_email       = "aweiss@aviatrix.com"
  avx_password      = "pMR%35*>SC?VPwMh"
  avx_customer_id   = "aviatrix.com-abu-e8ea5d00-1689194403.159335"
  region            = "eu-central-1"
}
