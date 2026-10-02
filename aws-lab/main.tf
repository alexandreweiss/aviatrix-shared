#Create VPC
resource "aws_vpc" "vpc_r1" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "aws-${var.aws_r1_location_short}-transit-${var.customer_name}"
  }
}

#Create route tables
resource "aws_route_table" "rt" {
  for_each = toset(["rt-avx-gw", "rt-avx-hagw", "rt-internal-a", "rt-internal-b", "rt-public-a", "rt-public-b", "rt-internal-bgp-lan-a", "rt-internal-bgp-lan-b"])
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
resource "aws_route" "route" {
  #Filter route tables that are internal
  for_each = { for k, v in aws_route_table.rt : k => v if length(regexall("rt-internal.*", k)) == 0 }

  route_table_id         = each.value.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.tgw.id
}

#Create subnets and associate created route tables
resource "aws_subnet" "subnet" {
  for_each          = toset(["subnet-internal-a", "subnet-internal-b", "subnet-public-a", "subnet-public-b", "subnet-internal-bgp-lan-a", "subnet-internal-bgp-lan-b"])
  vpc_id            = aws_vpc.vpc_r1.id
  cidr_block        = each.key == "subnet-internal-a" ? cidrsubnet(var.vpc_cidr, 4, 0) : each.key == "subnet-internal-b" ? cidrsubnet(var.vpc_cidr, 4, 1) : each.key == "subnet-public-a" ? cidrsubnet(var.vpc_cidr, 4, 2) : each.key == "subnet-public-b" ? cidrsubnet(var.vpc_cidr, 4, 3) : each.key == "subnet-internal-bgp-lan-a" ? cidrsubnet(var.vpc_cidr, 4, 4) : cidrsubnet(var.vpc_cidr, 4, 5)
  availability_zone = each.key == "subnet-internal-a" || each.key == "subnet-public-a" || each.key == "subnet-internal-bgp-lan-a" ? "${var.aws_r1_location}a" : "${var.aws_r1_location}b"

  tags = {
    Name = format("%s-%s", "${var.aws_r1_location_short}-transit-${var.customer_name}", each.key)
  }
}

#Associate route tables to subnets
resource "aws_route_table_association" "rt-association" {
  for_each = aws_subnet.subnet

  subnet_id      = each.value.id
  route_table_id = aws_route_table.rt[replace(each.key, "subnet-", "rt-")].id
}


#Create an AWS TGW associated to vpc
resource "aws_ec2_transit_gateway" "tgw" {
  description = format("%s-tgw", "${var.aws_r1_location_short}-${var.customer_name}")
  tags = {
    Name = format("%s-tgw", "${var.aws_r1_location_short}-transit-${var.customer_name}-tgw")
  }
}

#Create a TGW attachment to VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_transit_attach" {
  subnet_ids         = [aws_subnet.subnet["subnet-internal-bgp-lan-a"].id, aws_subnet.subnet["subnet-internal-bgp-lan-b"].id]
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = aws_vpc.vpc_r1.id
}

#Create Virtual Private Gateway
# resource "aws_vpn_gateway" "vgw" {
#   vpc_id          = aws_vpc.vpc_r1.id
#   amazon_side_asn = 64901
#   tags = {
#     Name = format("%s-vgw", "${var.aws_r1_location_short}-transit-${var.customer_name}-vgw")
#   }
# }

#Create a Direct Connect Gateway
resource "aws_dx_gateway" "dxgw" {
  amazon_side_asn = 64900
  name            = format("%s-dxgw", "${var.aws_r1_location_short}-${var.customer_name}-dxgw")
}

#Create a Direct Connect Gateway Association
resource "aws_dx_gateway_association" "dxgw_assoc" {
  dx_gateway_id         = aws_dx_gateway.dxgw.id
  associated_gateway_id = aws_ec2_transit_gateway.tgw.id
  allowed_prefixes      = ["0.0.0.0/0"]
}
