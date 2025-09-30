// APP SPOKE in AWS R1

#Create VPC

variable "gw_subnet" {
  default = "10.52.0.0/24"
}

variable "vpc_cidr" {
  default = "10.52.0.0/24"
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "aws-${var.aws_r1_location_short}-spoke-oai-vn"
  }
}

#Create route tables
resource "aws_route_table" "this" {
  for_each = toset(["avx-gw", "avx-hagw", "rt-internal-a", "rt-internal-b"])
  vpc_id   = aws_vpc.this.id

  tags = {
    Name = format("%s-%s", "${var.aws_r1_location_short}-spoke-oai", each.value)
  }
}

#Create IGW
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = format("%s-igw", "${var.aws_r1_location_short}-spoke-oai")
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

  cloud            = "AWS"
  name             = "aws-oai-spoke"
  cidr             = var.vpc_cidr
  region           = var.aws_r1_location
  account          = var.aws_account
  transit_gw       = module.aws_transit_oai.transit_gateway.gw_name
  attached         = true
  use_existing_vpc = true
  single_ip_snat   = true
  vpc_id           = aws_vpc.this.id
  gw_subnet        = aws_subnet.this["avx-gw-subnet"].cidr_block
  ha_gw            = false
  single_az_ha     = false
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/*ubuntu-noble-24.04-amd64-server-*"]
  }
}

module "ec2_instance_linux" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "aws-${var.aws_r1_location_short}-oai-srv"

  ami                         = data.aws_ami.ubuntu.image_id
  instance_type               = "t3.medium"
  key_name                    = "ssh-linux-non-prod"
  monitoring                  = true
  subnet_id                   = aws_subnet.this["front-a"].id
  vpc_security_group_ids      = [aws_security_group.allow_all_rfc1918.id]
  associate_public_ip_address = false

  tags = {
    Cloud       = "AWS"
    Application = "Dev Server"
  }
}

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

module "aws_transit_oai" {
  source = "terraform-aviatrix-modules/mc-transit/aviatrix"

  cloud           = "aws"
  region          = var.aws_r1_location
  cidr            = "10.58.0.0/23"
  account         = var.aws_account
  local_as_number = 65011
  name            = "aws-oai-transit"
  ha_gw           = false
  single_az_ha    = false
  tags = {
    csp-environment : "tst",
    csp-department : "dept-530",
    shutdown : "stop",
    schedule : "08:00-11:00;mo,tu,we,th,fr;europe-paris"
  }
}
