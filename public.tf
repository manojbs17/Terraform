resource "aws_internet_gateway" "amc-vpc-igw" {
  vpc_id = aws_vpc.amc-vpc.id
  tags   = merge(var.tags, {Name = "amc-vpc-igw"})
}

resource "aws_subnet" "public_a" {
  vpc_id            = aws_vpc.amc-vpc.id
  tags              = merge(var.tags, {Name = "public_a"})
  cidr_block        = var.subnets.a
  availability_zone = "ap-south-1a"
}

resource "aws_subnet" "public_b" {
  vpc_id            = aws_vpc.amc-vpc.id
  tags              = merge(var.tags, {Name = "public_b"})
  cidr_block        = var.subnets.b
  availability_zone = "ap-south-1b"
}

resource "aws_eip" "eip_a" {
 // public_ip = "13.202.127.184"
  tags = merge(var.tags, {Name = "eip_a"})
}

resource "aws_eip" "eip_b" {
 // public_ip = "13.234.200.206"
  tags = merge(var.tags, {Name = "eip_b"})
}

resource "aws_nat_gateway" "nat-gw-2a-public" {
  allocation_id = aws_eip.eip_a.id
  subnet_id     = aws_subnet.public_a.id
  tags      = merge(var.tags, {Name = "nat-gw-2a-public"})
  depends_on = [aws_eip.eip_a]
}

resource "aws_nat_gateway" "nat-gw-2b-public" {
  allocation_id = aws_eip.eip_b.id
  subnet_id     = aws_subnet.public_b.id
  tags      = merge(var.tags, {Name = "nat-gw-2b-public"})
  depends_on = [aws_eip.eip_b]
}

resource "aws_route_table" "rt_public_a" {
  vpc_id = aws_vpc.amc-vpc.id
   tags   = merge(var.tags, {Name = "rt_public_a"})
}

resource "aws_route_table_association" "rt_assoc_public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.rt_public_a.id
}

resource "aws_route" "route_a" {
  route_table_id            = aws_route_table.rt_public_a.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.amc-vpc-igw.id
}

resource "aws_route_table" "rt_public_b" {
  vpc_id = aws_vpc.amc-vpc.id
  tags   = merge(var.tags, {Name = "rt_public_b"})
}

resource "aws_route_table_association" "rt_assoc_public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.rt_public_b.id
}

resource "aws_route" "route_b" {
  route_table_id            = aws_route_table.rt_public_b.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.amc-vpc-igw.id
}