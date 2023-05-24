# Create the VPC peering connection
resource "aws_vpc_peering_connection" "peering" {  
  peer_vpc_id = aws_vpc.mongovpc.id
  vpc_id      = aws_vpc.appvpc.id
  auto_accept = true
}
resource "aws_route" "vpc_appvpc_to_vpc_mongovpc" {
  route_table_id         = aws_route_table.app-pubroute.id
  destination_cidr_block = aws_vpc.mongovpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}
resource "aws_route" "vpc_dbvpc_to_vpc_appvpc" {
  route_table_id         = aws_route_table.mongo-pubroute.id
  destination_cidr_block = aws_vpc.appvpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peering.id
}

