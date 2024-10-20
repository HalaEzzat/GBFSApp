resource "aws_vpc" "gbfs_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = { Name = "gbfs-vpc" }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.gbfs_vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags = { Name = "public-subnet" }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.gbfs_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = { Name = "private-subnet" }
}

# Internet Gateway to allow outbound access from public subnet
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.gbfs_vpc.id
  tags = { Name = "internet-gateway" }
}

# Route Table for Public Subnet
resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.gbfs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route.id
}
