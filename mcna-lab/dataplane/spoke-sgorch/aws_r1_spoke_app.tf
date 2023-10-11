// APP SPOKE in AWS R1
variable "region" {
  default = "eu-west-1"
}

variable "name" {
  default = "fra-spoke-app-a"
}

variable "gw_subnet" {
  default = "100.64.1.0/24"
}

variable "vpc_cidr" {
  default = "10.10.4.0/24"
}

data "dns_a_record_set" "controller_ip" {
  host = var.controller_fqdn
}


#Create VPC
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "aws-${var.aws_r1_location_short}-spoke-app-a"
  }
}

#Add secondary CIDR
resource "aws_vpc_ipv4_cidr_block_association" "this" {
  vpc_id     = aws_vpc.this.id
  cidr_block = var.gw_subnet
}

#Create route tables
resource "aws_route_table" "this" {
  for_each = toset(["avx-gw", "avx-hagw", "rt-internal-a", "rt-internal-b", "public1", "public2"])
  vpc_id   = aws_vpc.this.id

  tags = {
    Name = format("%s-%s", var.name, each.value)
  }
}

#Create IGW
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = format("%s-igw", var.name)
  }
}

#Install default route in public route tables
resource "aws_route" "this" {
  #Filter route tables that are internal
  for_each = { for k, v in aws_route_table.this : k => v if length(regexall("rt-internal.*", k)) == 0 }

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

#Define subnet parameters in a local variable
locals {
  subnets = {
    avx-gw-subnet = {
      route_table       = "avx-gw",
      cidr              = cidrsubnet(var.gw_subnet, 1, 0)
      availability_zone = "a"
    },
    avx-hagw-subnet = {
      route_table       = "avx-hagw",
      cidr              = cidrsubnet(var.gw_subnet, 1, 1)
      availability_zone = "b"
    },
    front-a = {
      route_table       = "rt-internal-a",
      cidr              = cidrsubnet(var.vpc_cidr, 4, 0)
      availability_zone = "a"
    },
    back-a = {
      route_table       = "rt-internal-a",
      cidr              = cidrsubnet(var.vpc_cidr, 4, 1)
      availability_zone = "a"
    },
    front-b = {
      route_table       = "rt-internal-b",
      cidr              = cidrsubnet(var.vpc_cidr, 4, 2)
      availability_zone = "b"
    },
    back-b = {
      route_table       = "rt-internal-b",
      cidr              = cidrsubnet(var.vpc_cidr, 4, 3)
      availability_zone = "b"
    },
    public1 = {
      route_table       = "public1",
      cidr              = cidrsubnet(var.vpc_cidr, 4, 4)
      availability_zone = "a"
    },
    public2 = {
      route_table       = "public1",
      cidr              = cidrsubnet(var.vpc_cidr, 4, 5)
      availability_zone = "a"
    },
    public3 = {
      route_table       = "public2",
      cidr              = cidrsubnet(var.vpc_cidr, 4, 6)
      availability_zone = "b"
    },
    public4 = {
      route_table       = "public2",
      cidr              = cidrsubnet(var.vpc_cidr, 4, 7)
      availability_zone = "b"
    },
  }
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

#Create all subnets
resource "aws_subnet" "this" {
  for_each   = local.subnets
  vpc_id     = aws_vpc.this.id
  cidr_block = each.value.cidr

  tags = {
    Name = each.key
  }

  depends_on = [
    aws_vpc_ipv4_cidr_block_association.this
  ]
}

#Associate all subnets with designated route tables
resource "aws_route_table_association" "this" {
  for_each = local.subnets

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.this[each.value.route_table].id
}

//Spoke GW
module "aws_r1_spoke_app_a" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.6.3"

  cloud   = "AWS"
  name    = "${var.aws_r1_location_short}-spoke-app-a"
  cidr    = "10.10.4.0/24"
  region  = var.aws_r1_location
  account = var.aws_account
  //transit_gw       = data.tfe_outputs.dataplane.values.aws_transit_r1.transit_gateway.gw_name
  attached         = false
  use_existing_vpc = true
  vpc_id           = aws_vpc.this.id
  gw_subnet        = aws_subnet.this["avx-gw-subnet"].cidr_block
  hagw_subnet      = aws_subnet.this["avx-hagw-subnet"].cidr_block
  ha_gw            = false
  single_az_ha     = false
}

# Microseg intra VPC

## Enable VPC for MicroSeg
resource "aviatrix_distributed_firewalling_intra_vpc" "this" {
  vpcs {
    account_name = var.aws_account
    vpc_id       = aws_vpc.this.id
    region       = var.aws_r1_location
  }
}

# Smart Groups
resource "aviatrix_smart_group" "app-a-back" {
  name = "app-a-back"
  selector {
    match_expressions {
      type = "vm"
      tags = {
        "Application" = "RDS"
      }
    }
    # match_expressions {
    #   cidr = aws_subnet.this["back-a"].cidr_block
    # }
    # match_expressions {
    #   cidr = aws_subnet.this["back-b"].cidr_block
    # }
  }
}

resource "aviatrix_smart_group" "app-a-front" {
  name = "app-a-front"
  selector {
    match_expressions {
      type = "vm"
      tags = {
        "Application" = "Jump Server"
      }
    }
    # match_expressions {
    #   cidr = aws_subnet.this["front-a"].cidr_block
    # }
    # match_expressions {
    #   cidr = aws_subnet.this["front-b"].cidr_block
    # }
  }
}

resource "aviatrix_smart_group" "my-source-ip" {
  name = "my-source-ip"
  selector {
    match_expressions {
      cidr = "${chomp(data.http.myip.response_body)}/32"
    }
    match_expressions {
      cidr = "81.49.43.155/32"
    }
  }
}

# DCF Firewall rule
resource "aviatrix_distributed_firewalling_policy_list" "policy" {
  policies {
    action           = "PERMIT"
    src_smart_groups = [aviatrix_smart_group.my-source-ip.uuid]
    name             = "AllowMySourceIPToFront-HTTP"
    protocol         = "TCP"
    port_ranges {
      lo = 443
    }
    # port_ranges {
    #   lo = 22
    # }
    dst_smart_groups = [aviatrix_smart_group.app-a-front.uuid]
    logging          = true
    priority         = 100
  }
  policies {
    action           = "PERMIT"
    src_smart_groups = [aviatrix_smart_group.app-a-front.uuid]
    name             = "AllowFrontToBack-RDP"
    protocol         = "TCP"
    port_ranges {
      lo = 3389
    }
    dst_smart_groups = [aviatrix_smart_group.app-a-back.uuid]
    logging          = true
    priority         = 150
  }
  # policies {
  #   action           = "DENY"
  #   src_smart_groups = [aviatrix_smart_group.app-a-front.uuid]
  #   name             = "DenyFrontToBack"
  #   protocol         = "Any"
  #   dst_smart_groups = [aviatrix_smart_group.app-a-back.uuid]
  #   logging          = true
  #   priority         = 500
  # }
  # policies {
  #   action           = "PERMIT"
  #   src_smart_groups = ["def000ad-0000-0000-0000-000000000000"]
  #   name             = "Greenfield-Rule-Custom"
  #   protocol         = "Any"
  #   dst_smart_groups = ["def000ad-0000-0000-0000-000000000000"]
  #   logging          = true
  #   priority         = 2000000000
  # }
}

# Workload VMs

# Guacamole
## SSH Key Pair
module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"

  key_name           = "spoke_app_ssh_key"
  create_private_key = true
}

## Guacamole image search
data "aws_ami" "guacamole" {
  most_recent = true

  filter {
    name   = "owner-id"
    values = ["679593333241"]
  }

  filter {
    name   = "name"
    values = ["bitnami-guacamole-1.4.0-73-r42*-x86_64-hvm-ebs*"]
  }
}

## Deploy Guacamole AMI for remote desktop access to the Windows host in VPC1. Configuration happens in the separate "config-guacamole" Terraform plan
module "ec2_instance_guacamole" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "guacamole-jump-server"

  ami           = data.aws_ami.guacamole.image_id
  instance_type = "t3a.small"
  key_name      = module.key_pair.key_pair_name
  monitoring    = true
  #vpc_security_group_ids      = [aws_security_group.allow_web_ssh_public[0].id, aws_security_group.allow_all_rfc1918[0].id]
  subnet_id                   = aws_subnet.this["front-a"].id
  associate_public_ip_address = true

  tags = {
    Cloud       = "AWS"
    Application = "Jump Server"
  }
}

## Assign an EIP to Guacamole so that the URL doesn't change across reboots
resource "aws_eip" "guacamole" {
  vpc = true

  instance                  = module.ec2_instance_guacamole.id
  associate_with_private_ip = module.ec2_instance_guacamole.private_ip
}


## Wait for the Guacamole instance to deploy
resource "time_sleep" "guacamole_ready" {
  depends_on = [module.ec2_instance_guacamole]

  create_duration = "250s"
}

## SSH to the Guacamole instance and get the UI login
resource "ssh_resource" "guac_password" {
  # The default behaviour is to run file blocks and commands at create time
  # You can also specify 'destroy' to run the commands at destroy time
  when = "create"

  host        = aws_eip.guacamole.public_dns
  user        = "bitnami"
  private_key = module.key_pair.private_key_pem

  timeout = "15m"

  commands = [
    "sudo cat /home/bitnami/bitnami_credentials"
  ]
  depends_on = [
    time_sleep.guacamole_ready
  ]
}

# Windows VM

data "aws_ami" "windows" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

## Deploy Windows Jump Host in VPC1, AZ1
module "ec2_instance_windows" {

  source = "terraform-aws-modules/ec2-instance/aws"

  name = "windows-vm"

  ami           = data.aws_ami.windows.image_id
  instance_type = "t3a.small"
  key_name      = module.key_pair.key_pair_name
  monitoring    = true
  //vpc_security_group_ids      = [aws_security_group.allow_all_rfc1918[0].id]
  subnet_id                   = aws_subnet.this["back-a"].id
  associate_public_ip_address = false
  //user_data                   = file("windows_init.txt")
  get_password_data = true

  tags = {
    OS          = "Windows"
    Application = "RDS"
  }
  #   lifecycle {
  #     ignore_changes = [ami, ]
  #   }

}
