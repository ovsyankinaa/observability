resource "aws_vpc" "public" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    {
      Name = "${var.n_s}-vpc"
    },
  )
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.public.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.n_s}-subnet-${data.aws_availability_zones.available.names[0]}"
    },
  )
}

resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.public.id

  tags = merge(
    var.tags,
    {
      Name = "${var.n_s}-igw"
    },
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.public.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public.id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.n_s}-rt"
    },
  )
}

resource "aws_main_route_table_association" "public" {
  vpc_id         = aws_vpc.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}