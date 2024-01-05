// APP SPOKE in AWS R1
variable "region" {
  default = "eu-west-1"
}

variable "gw_subnet" {
  default = "100.64.1.0/24"
}

variable "vpc_cidr" {
  default = "10.52.0.0/24"
}

#Create VPC
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "aws-${var.aws_r1_location_short}-spoke-${var.application_1}-${var.customer_name}"
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
    Name = format("%s-%s", "${var.aws_r1_location_short}-spoke-${var.application_1}-${var.customer_name}", each.value)
  }
}

#Create IGW
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = format("%s-igw", "${var.aws_r1_location_short}-spoke-${var.application_1}-${var.customer_name}")
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
module "aws_r1_spoke_app1" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.6.3"

  cloud            = "AWS"
  name             = "aws-${var.aws_r1_location_short}-spoke-${var.application_1}-${var.customer_name}"
  cidr             = var.vpc_cidr
  region           = var.aws_r1_location
  account          = var.aws_account
  transit_gw       = data.tfe_outputs.dataplane.values.aws_transit_r1.transit_gateway.gw_name
  attached         = true
  use_existing_vpc = true
  single_ip_snat   = true
  vpc_id           = aws_vpc.this.id
  gw_subnet        = aws_subnet.this["avx-gw-subnet"].cidr_block
  hagw_subnet      = aws_subnet.this["avx-hagw-subnet"].cidr_block
  ha_gw            = false
  single_az_ha     = false
}

# Workload VMs

## SSH Key Pair
# module "key_pair" {
#   source = "terraform-aws-modules/key-pair/aws"

#   key_name           = "ssh-linux-non-prod"
#   create_private_key = true
# }

## Linux image search
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"]
  }
}

## Deploy Guacamole AMI for remote desktop access to the Windows host in VPC1. Configuration happens in the separate "config-guacamole" Terraform plan
module "ec2_instance_linux" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = var.application_1

  ami                         = data.aws_ami.ubuntu.image_id
  instance_type               = "t3a.small"
  key_name                    = "ssh-linux-non-prod"
  monitoring                  = true
  subnet_id                   = aws_subnet.this["front-a"].id
  associate_public_ip_address = false

  tags = {
    Cloud       = "AWS"
    Application = "Dev Server"
  }
}

# Windows VM

# data "aws_ami" "windows" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["Windows_Server-2022-English-Full-Base-*"]
#   }
#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }
#   filter {
#     name   = "owner-alias"
#     values = ["amazon"]
#   }
# }

# ## Deploy Windows Jump Host in VPC1, AZ1
# module "ec2_instance_windows" {

#   source = "terraform-aws-modules/ec2-instance/aws"

#   name = "windows-vm"

#   ami           = data.aws_ami.windows.image_id
#   instance_type = "t3a.small"
#   key_name      = module.key_pair.key_pair_name
#   monitoring    = true
#   //vpc_security_group_ids      = [aws_security_group.allow_all_rfc1918[0].id]
#   subnet_id                   = aws_subnet.this["back-a"].id
#   associate_public_ip_address = false
#   //user_data                   = file("windows_init.txt")
#   get_password_data = true

#   tags = {
#     OS          = "Windows"
#     Application = "RDS"
#   }
#   #   lifecycle {
#   #     ignore_changes = [ami, ]
#   #   }

# }
