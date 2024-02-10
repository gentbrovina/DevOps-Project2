resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc-eks"
  }
}

resource "aws_internet_gateway" "internet-gateway" {
  vpc_id    = aws_vpc.main.id

  tags      = {
    Name    = " igw"
  }
}

resource "aws_subnet" "private-us-east-1a" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.0.0/19"
    availability_zone = "us-east-1a"
  
  tags = {
    "Name" = "private-us-east-1a"
    "kubernetes.io/role/intetrnal-elb" = "1"
    "kubernetes.io/cluster/demo" = "owned"
  }
}
resource "aws_subnet" "private-us-east-1b" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.32.0/19"
    availability_zone = "us-east-1b"
  
  tags = {
    "Name" = "private-us-east-1b"
    "kubernetes.io/role/intetrnal-elb" = "1"
    "kubernetes.io/cluster/demo" = "owned"
  }
}
resource "aws_subnet" "public-us-east-1a" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.64.0/19"
    availability_zone = "us-east-1a"
  
  tags = {
    "Name" = "private-us-east-1a"
    "kubernetes.io/role/intetrnal-elb" = "1"
    "kubernetes.io/cluster/demo" = "owned"
  }
}
resource "aws_subnet" "public-us-east-1b" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.96.0/19"
    availability_zone = "us-east-1b"
  
  tags = {
    "Name" = "private-us-east-1b"
    "kubernetes.io/role/intetrnal-elb" = "1"
    "kubernetes.io/cluster/demo" = "owned"
  }
}
resource "aws_eip" "nat_eip" {
    vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  depends_on = [aws_eip.nat_eip]
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.public-us-east-1a.id
  tags = {
    "Name" = "nat_gateway"
  }
}

resource "aws_route_table" "public-route-table" {
  vpc_id       = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet-gateway.id
  }

  tags       = {
    Name     = "Public Route Table"
  }
}

resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id

    route = [
        {
            cidr_block = "0.0.0.0/0"
            nat_gateway_id = aws_nat_gateway.nat.id
            carrier_gateway_id = ""
            destination_prefix_list_id = ""
            egress_only_gateway_id = ""
            gateway_id = ""
            instance_id = ""
            ipv6_cide_block = ""
            local_gateway_id = ""
            network_interface_id = ""
            transit_gateway_id = ""
            vpc_endpoint_id = ""
            vpc_peering_connection_id = ""
        },
    ]
  tags = {
    Name = "private"
  }
}
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route = [
        {
            cidr_block = "0.0.0.0/0"
            gateway_id = aws_internet_gateway.igw.id
            nat_gateway_id = aws_nat_gateway.nat.id
            carrier_gateway_id = ""
            destination_prefix_list_id = ""
            egress_only_gateway_id = ""
            gateway_id = ""
            instance_id = ""
            ipv6_cide_block = ""
            local_gateway_id = ""
            network_interface_id = ""
            transit_gateway_id = ""
            vpc_endpoint_id = ""
            vpc_peering_connection_id = ""
        },
    ]
  tags = {
    Name = "public"
  }
}
resource "aws_route_table_association" "private-us-east-1b" {
  subnet_id           = aws_subnet.private-us-east-1b.id
  route_table_id      = aws_route_table.private.id
}
resource "aws_route_table_association" "public-us-east-1a" {
  subnet_id           = aws_subnet.public-us-east-1a.id
  route_table_id      = aws_route_table.public.id
}
resource "aws_route_table_association" "private-us-east-1b" {
  subnet_id           = aws_subnet.private-us-east-1b.id
  route_table_id      = aws_route_table.private.id
}