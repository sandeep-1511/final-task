#Create the vpc
resource "aws_vpc" "appvpc" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "appvpc"
  }
}


#Creating pub-subnet1
resource "aws_subnet" "pubsub-1" {
  vpc_id                  = aws_vpc.appvpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = "true"
  tags = {

    Name = "pubsubnet-1"
  }

}
#Creating private subnet1
resource "aws_subnet" "pvtsub-1" {
  vpc_id                  = aws_vpc.appvpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "pvtsubnet-1"
  }
}
#Creating pub-subnet2
resource "aws_subnet" "pubsub-2" {
  vpc_id                  = aws_vpc.appvpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = "true"
  tags = {

    Name = "pubsubnet-2"
  }

}

#Creating pvt-subnet2
resource "aws_subnet" "pvtsub-2" {
  vpc_id                  = aws_vpc.appvpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "pvtsubnet-2"
  }
}

#Creating pvt-subnet3
resource "aws_subnet" "pvtsub-3" {
  vpc_id                  = aws_vpc.appvpc.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "pvtsubnet-3"
  }
}

#Creating pvt-subnet4
resource "aws_subnet" "pvtsub-4" {
  vpc_id                  = aws_vpc.appvpc.id
  cidr_block              = "10.0.6.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "pvtsubnet-4"
  }
}

#Creating IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.appvpc.id
  tags = {

    Name = "app-igw"
  }
}

# Create elastic ip
resource "aws_eip" "eip-1" {
  vpc = true
}
# Create Nat-gateway
resource "aws_nat_gateway" "nat-1" {

  allocation_id     = aws_eip.eip-1.id
  subnet_id         = aws_subnet.pubsub-1.id
  connectivity_type = "public"
  tags = {
    Name = "appnat-1"
  }
}
# Create elastic ip
resource "aws_eip" "eip-2" {
  vpc = true
}

# Create Nat-gateway
resource "aws_nat_gateway" "nat-2" {

  allocation_id     = aws_eip.eip-2.id
  subnet_id         = aws_subnet.pubsub-2.id
  connectivity_type = "public"
  tags = {
    Name = "appnat-2"
  }
}
#Create Pub-Route-table
resource "aws_route_table" "app-pubroute" {
  vpc_id = aws_vpc.appvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id

  }
  tags = {
    Name = "apppub-rt"
  }

}

#Create Pvt-Route-table
resource "aws_route_table" "app-pvtroute-1" {
  vpc_id = aws_vpc.appvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-1.id
  }

  tags = {
    Name = "apppvt-rt-1"
  }

}

#Create Pvt-Route-table
resource "aws_route_table" "app-pvtroute-2" {
  vpc_id = aws_vpc.appvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-2.id
  }

  tags = {
    Name = "apppvt-rt-2"
  }

}
#Create Pvt-Route-table
resource "aws_route_table" "app-pvtroute-3" {
  vpc_id = aws_vpc.appvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-1.id
  }

  tags = {
    Name = "apppvt-rt-3"
  }
}

#Create Pvt-Route-table
resource "aws_route_table" "app-pvtroute-4" {
  vpc_id = aws_vpc.appvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat-2.id
  }

  tags = {
    Name = "apppvt-rt-4"
  }
}
#subnets Associations
#pub-subnet-association
resource "aws_route_table_association" "pub-1" {
  subnet_id      = aws_subnet.pubsub-1.id
  route_table_id = aws_route_table.app-pubroute.id
}

#pvt subnet-association
resource "aws_route_table_association" "pvt-1" {
  subnet_id      = aws_subnet.pvtsub-1.id
  route_table_id = aws_route_table.app-pvtroute-1.id

}

#subnets Associations
#pub-subnet-association
resource "aws_route_table_association" "pub-2" {
  subnet_id      = aws_subnet.pubsub-2.id
  route_table_id = aws_route_table.app-pubroute.id
}
#pvt subnet-association
resource "aws_route_table_association" "pvt-2" {
  subnet_id      = aws_subnet.pvtsub-2.id
  route_table_id = aws_route_table.app-pvtroute-2.id

}
#pvt subnet-association
resource "aws_route_table_association" "pvt-3" {
  subnet_id      = aws_subnet.pvtsub-3.id
  route_table_id = aws_route_table.app-pvtroute-3.id

}
#pvt subnet-association
resource "aws_route_table_association" "pvt-4" {
  subnet_id      = aws_subnet.pvtsub-4.id
  route_table_id = aws_route_table.app-pvtroute-4.id

}

