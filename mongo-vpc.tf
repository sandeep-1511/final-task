#Create the vpc
resource "aws_vpc" "mongovpc" {
  cidr_block       = "192.168.0.0/16"

  tags = {
    Name = "mongovpc"
  }
}
#Creating IGW
resource "aws_internet_gateway" "mongo-igw" {
  vpc_id = aws_vpc.mongovpc.id
  tags = {

    Name = "mongo-igw"
  }
}

#Creating pub-subnet1
resource "aws_subnet" "mongo-pubsub-1" {
  vpc_id                  = aws_vpc.mongovpc.id
  cidr_block              = "192.168.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = "true"
  tags = {

    Name = "mongo-pubsubnet-1"
  }

}
#Creating private subnet1
resource "aws_subnet" "mongo-pvtsub-1" {
  vpc_id                  = aws_vpc.mongovpc.id
  cidr_block              = "192.168.2.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "mongo-pvtsubnet-1"
  }
}
#Creating pub-subnet2
resource "aws_subnet" "mongo-pubsub-2" {
  vpc_id                  = aws_vpc.mongovpc.id
  cidr_block              = "192.168.3.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = "true"
  tags = {

    Name = "mongo-pubsubnet-2"
  }

}

#Creating pvt-subnet2
resource "aws_subnet" "mongo-pvtsub-2" {
  vpc_id                  = aws_vpc.mongovpc.id
  cidr_block              = "192.168.4.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "mongo-pvtsubnet-2"
  }
}

#Creating pvt-subnet3
resource "aws_subnet" "mongo-pvtsub-3" {
  vpc_id                  = aws_vpc.mongovpc.id
  cidr_block              = "192.168.5.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "mongo-pvtsubnet-3"
  }
}

#Creating pvt-subnet4
resource "aws_subnet" "mongo-pvtsub-4" {
  vpc_id                  = aws_vpc.mongovpc.id
  cidr_block              = "192.168.6.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "mongo-pvtsubnet-4"
  }
}

# Create elastic ip
resource "aws_eip" "mongo-eip-01" {
  vpc = true
}
# Create Nat-gateway
resource "aws_nat_gateway" "mongo-nat-01" {

  allocation_id     = aws_eip.mongo-eip-01.id
  subnet_id         = aws_subnet.mongo-pubsub-1.id
  connectivity_type = "public"
  tags = {
    Name = "mongonat-1"
  }
}
# Create elastic ip
resource "aws_eip" "mongo-eip-02" {
  vpc = true
}

# Create Nat-gateway
resource "aws_nat_gateway" "mongo-nat-02" {

  allocation_id     = aws_eip.mongo-eip-02.id
  subnet_id         = aws_subnet.mongo-pubsub-2.id
  connectivity_type = "public"
  tags = {
    Name = "mongonat-2"
  }
}
#Create Pub-Route-table
resource "aws_route_table" "mongo-pubroute" {
  vpc_id = aws_vpc.mongovpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mongo-igw.id

  }
  tags = {
    Name = "mongo-pubrt"
  }

}

#Create Pvt-Route-table
resource "aws_route_table" "mongo-pvtroute-1" {
  vpc_id = aws_vpc.mongovpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.mongo-nat-01.id
  }

  tags = {
    Name = "mongo-pvtrt-1"
  }

}

#Create Pvt-Route-table
resource "aws_route_table" "mongo-pvtroute-2" {
  vpc_id = aws_vpc.mongovpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.mongo-nat-02.id
  }

  tags = {
    Name = "mongo-pvtrt-2"
  }

}
#Create Pvt-Route-table
resource "aws_route_table" "mongo-pvtroute-3" {
  vpc_id = aws_vpc.mongovpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.mongo-nat-01.id
  }

  tags = {
    Name = "mongo-pvtrt-3"
  }
}

#Create Pvt-Route-table
resource "aws_route_table" "mongo-pvtroute-4" {
  vpc_id = aws_vpc.mongovpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.mongo-nat-02.id
  }

  tags = {
    Name = "mongo-pvtrt-4"
  }
}
#subnets Associations
#pub-subnet-association
resource "aws_route_table_association" "mongo-pub-1" {
  subnet_id      = aws_subnet.mongo-pubsub-1.id
  route_table_id = aws_route_table.mongo-pubroute.id
}
#pvt subnet-association
resource "aws_route_table_association" "mongo-pvt-1" {
  subnet_id      = aws_subnet.mongo-pvtsub-1.id
  route_table_id = aws_route_table.mongo-pvtroute-1.id

}


#subnets Associations
#pub-subnet-association
resource "aws_route_table_association" "mongo-pub-2" {
  subnet_id      = aws_subnet.mongo-pubsub-2.id
  route_table_id = aws_route_table.mongo-pubroute.id
}
#pvt subnet-association
resource "aws_route_table_association" "mongo-pvt-2" {
  subnet_id      = aws_subnet.mongo-pvtsub-2.id
  route_table_id = aws_route_table.mongo-pvtroute-2.id

}
#pvt subnet-association
resource "aws_route_table_association" "mongo-pvt-3" {
  subnet_id      = aws_subnet.mongo-pvtsub-3.id
  route_table_id = aws_route_table.mongo-pvtroute-3.id

}
#pvt subnet-association
resource "aws_route_table_association" "mongo-pvt-4" {
  subnet_id      = aws_subnet.mongo-pvtsub-4.id
  route_table_id = aws_route_table.mongo-pvtroute-4.id

}

