// APP SPOKE in AWS R1
variable "region" {
  default = "eu-west-1"
}

variable "gw_subnet" {
  # default = "100.64.1.0/24"
  default = "10.52.0.0/24"
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
# resource "aws_vpc_ipv4_cidr_block_association" "this" {
#   vpc_id     = aws_vpc.this.id
#   cidr_block = var.gw_subnet
# }

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
      route_table = "avx-gw",
      # cidr              = cidrsubnet(var.gw_subnet, 1, 0)
      cidr              = cidrsubnet(var.gw_subnet, 4, 8)
      availability_zone = "${var.aws_r1_location}a"
    },
    avx-hagw-subnet = {
      route_table = "avx-hagw",
      # cidr              = cidrsubnet(var.gw_subnet, 1, 1)
      cidr              = cidrsubnet(var.gw_subnet, 4, 9)
      availability_zone = "${var.aws_r1_location}c"
    },
    front-a = {
      route_table       = "rt-internal-a",
      cidr              = cidrsubnet(var.vpc_cidr, 4, 0)
      availability_zone = "${var.aws_r1_location}a"
    },
    back-a = {
      route_table       = "rt-internal-a",
      cidr              = cidrsubnet(var.vpc_cidr, 4, 1)
      availability_zone = "${var.aws_r1_location}a"
    },
    front-b = {
      route_table       = "rt-internal-b",
      cidr              = cidrsubnet(var.vpc_cidr, 4, 2)
      availability_zone = "${var.aws_r1_location}b"
    },
    back-b = {
      route_table       = "rt-internal-b",
      cidr              = cidrsubnet(var.vpc_cidr, 4, 3)
      availability_zone = "${var.aws_r1_location}b"
    },
    public1 = {
      route_table       = "public1",
      cidr              = cidrsubnet(var.vpc_cidr, 4, 4)
      availability_zone = "${var.aws_r1_location}a"
    },
    public2 = {
      route_table       = "public1",
      cidr              = cidrsubnet(var.vpc_cidr, 4, 5)
      availability_zone = "${var.aws_r1_location}a"
    },
    public3 = {
      route_table       = "public2",
      cidr              = cidrsubnet(var.vpc_cidr, 4, 6)
      availability_zone = "${var.aws_r1_location}b"
    },
    public4 = {
      route_table       = "public2",
      cidr              = cidrsubnet(var.vpc_cidr, 4, 7)
      availability_zone = "${var.aws_r1_location}b"
    },
  }
}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

#Create all subnets
resource "aws_subnet" "this" {
  for_each          = local.subnets
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.availability_zone

  tags = {
    Name = each.key
  }

  # depends_on = [
  #   aws_vpc_ipv4_cidr_block_association.this
  # ]
}

#Associate all subnets with designated route tables
resource "aws_route_table_association" "this" {
  for_each = local.subnets

  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.this[each.value.route_table].id
}

//Spoke GW
module "aws_r1_spoke_app1" {
  source = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  # version = "1.6.3"

  cloud   = "AWS"
  name    = "aws-${var.aws_r1_location_short}-spoke-${var.application_1}-${var.customer_name}"
  cidr    = var.vpc_cidr
  region  = var.aws_r1_location
  account = var.aws_account
  # transit_gw = data.tfe_outputs.dataplane.values.aws_transit_r1.transit_gateway.gw_name
  transit_gw       = data.tfe_outputs.dataplane.values.transit_we.transit_gateway.gw_name
  attached         = true
  use_existing_vpc = true
  single_ip_snat   = true
  vpc_id           = aws_vpc.this.id
  gw_subnet        = aws_subnet.this["avx-gw-subnet"].cidr_block
  # hagw_subnet      = aws_subnet.this["avx-hagw-subnet"].cidr_block
  ha_gw           = false
  single_az_ha    = false
  enable_bgp      = true
  local_as_number = 65001
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

######TEMP
data "aws_ami" "ubuntu-recent" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/*ubuntu-noble-24.04-amd64-server-*"]
  }
}

module "ec2_instance_linux_recent" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "${var.application_1}-recent"

  ami                         = data.aws_ami.ubuntu-recent.image_id
  instance_type               = "t3.medium"
  key_name                    = "ssh-linux-non-prod"
  monitoring                  = true
  subnet_id                   = aws_subnet.this["front-a"].id
  vpc_security_group_ids      = [aws_security_group.allow_all_rfc1918.id]
  associate_public_ip_address = false

  tags = {
    Cloud       = "AWS"
    Application = "Dev Server Recent"
  }
}

#######TEMP

# Deploy Guacamole AMI for remote desktop access to the Windows host in VPC1. Configuration happens in the separate "config-guacamole" Terraform plan
# module "ec2_instance_linux" {
#   source = "terraform-aws-modules/ec2-instance/aws"

#   name = var.application_1

#   ami                         = data.aws_ami.ubuntu.image_id
#   instance_type               = "t3a.small"
#   key_name                    = "ssh-linux-non-prod"
#   monitoring                  = true
#   subnet_id                   = aws_subnet.this["front-a"].id
#   vpc_security_group_ids      = [aws_security_group.allow_all_rfc1918.id]
#   associate_public_ip_address = false

#   tags = {
#     Cloud       = "AWS"
#     Application = "Dev Server"
#   }
# }

resource "aws_security_group" "allow_all_rfc1918" {
  name        = "allow_all_rfc1918_vpc"
  description = "allow_all_rfc1918_vpc"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/8", "192.168.0.0/16", "172.16.0.0/12"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_all_rfc1918_vpc"
  }
}

resource "aws_security_group" "allow_web_ssh_public" {
  name        = "allow_web_ssh_public"
  description = "allow_web_ssh_public"
  vpc_id      = aws_vpc.this.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 83
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.myip.response_body)}/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_web_ssh_public"
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
