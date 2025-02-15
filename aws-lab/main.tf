#Create VPC
resource "aws_vpc" "vpc_r1" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "aws-${var.aws_r1_location_short}-transit-${var.customer_name}"
  }
}

#Create route tables
resource "aws_route_table" "rt" {
  for_each = toset(["rt-avx-gw", "rt-avx-hagw", "rt-internal-a", "rt-internal-b", "rt-public-a", "rt-public-b"])
  vpc_id   = aws_vpc.vpc_r1.id

  tags = {
    Name = format("%s-%s", "${var.aws_r1_location_short}-transit-${var.customer_name}", each.value)
  }
}

#Create IGW
resource "aws_internet_gateway" "tgw" {
  vpc_id = aws_vpc.vpc_r1.id

  tags = {
    Name = format("%s-igw", "${var.aws_r1_location_short}-transit-${var.customer_name}")
  }
}

#Install default route in public route tables
resource "aws_route" "rt" {
  #Filter route tables that are internal
  for_each = { for k, v in aws_route_table.rt : k => v if length(regexall("rt-internal.*", k)) == 0 }

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.tgw.id
}