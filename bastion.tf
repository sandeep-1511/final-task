provider "aws" {
  region     = "ap-south-1"
}


# creating security groups
resource "aws_security_group" "demosg" {
  vpc_id = aws_vpc.mongovpc.id
# inbound rules
# httpd access from anywhere
ingress {
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
# ssh access from anywhere
ingress {
  from_port = 22
  to_port = 22
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
ingress {
    from_port = 27017
    to_port = 27017
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
# outbound rules
egress {
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = ["0.0.0.0/0"]
}
}


resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "terra_key_pair" {
  key_name   = "terra-key-1"
  public_key = tls_private_key.rsa.public_key_openssh
  depends_on = [aws_security_group.demosg]
}

output "private_key_pem" {
  value = tls_private_key.rsa.private_key_pem
  sensitive = true
}

resource "null_resource" "copy" {
  provisioner "local-exec" {
  command = <<-EOT
    echo "${tls_private_key.rsa.private_key_pem}" > terra-key-1.pem
    chmod 400 terra-key-1.pem
  EOT
 }
  depends_on = [aws_key_pair.terra_key_pair]
}

resource "aws_route53_zone" "stage" {
  name = "darwin.com"
}


resource "aws_route53_record"  "db" {
  count = 3
  zone_id = aws_route53_zone.stage.zone_id
  name = "db${count.index}.darwin.com" //name is db[0-1].darwin.com
  type = "A"
  ttl = "300"
  records = [aws_instance.mongo[count.index].private_ip]
}

resource "aws_instance" "bastion-host" {
  ami           = "ami-04cb430e5f6c04298"  # Replace with your desired AMI ID
  instance_type = "t2.micro"      # Replace with your desired instance type
  key_name      = aws_key_pair.terra_key_pair.key_name
  vpc_security_group_ids = [aws_security_group.demosg.id]  # Replace with the desired security group ID(s)
  subnet_id              = aws_subnet.mongo-pubsub-1.id  # Replace with the desired subnet ID

  tags = {
    Name = "Bastion-host"
  }
  depends_on = [null_resource.copy]
}

resource "aws_instance" "mongo" {
  count         = 3  # Set the desired count of instances
  ami           = "ami-04cb430e5f6c04298"  # Replace with your desired AMI ID
  instance_type = "t2.micro"      # Replace with your desired instance type
  key_name      = aws_key_pair.terra_key_pair.key_name

  vpc_security_group_ids = [aws_security_group.demosg.id]  # Replace with the desired security group ID(s)
  subnet_id              = aws_subnet.mongo-pvtsub-1.id # Replace with the desired subnet ID

  tags = {
    Name = "mongo-master-${count.index + 1}"
  }
}

resource "null_resource" "export_pem" {
  count = 3  # Set the same count as the number of instances

  provisioner "remote-exec" {
    inline = [
      "echo '${tls_private_key.rsa.private_key_pem}' > terra-key-1.pem",
      "chmod 400 terra-key-1.pem"
    ]
  }

  connection {
    type          = "ssh"
    user          = "ubuntu"
    private_key   = tls_private_key.rsa.private_key_pem
    host          = aws_instance.bastion-host.public_ip
    bastion_host  = aws_instance.bastion-host.public_ip
    bastion_user  = "ubuntu"
  }

  depends_on = [
    aws_instance.bastion-host,
  ]
}

resource "null_resource" "install_mongodb" {
  count = 3  # Set the same count as the number of instances

  depends_on = [
    null_resource.export_pem
  ]


provisioner "remote-exec" {
  inline = [
    "sudo apt-get update",
    "sudo apt-get install -y gnupg",
    "wget -qO - https://www.mongodb.org/static/pgp/server-5.0.asc | sudo apt-key add -",
    "echo 'deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/5.0 multiverse' | sudo tee /etc/apt/sources.list.d/mongodb-org-5.0.list",
    "sudo apt-get update",
    "sudo apt-get install -y mongodb-org",
    "sudo sed -i 's/#replication:/replication:\\n  replSetName: \"rs1\"/g' /etc/mongod.conf",
    "sudo systemctl start mongod",
    "sudo systemctl enable mongod",
    "sudo sed -i 's/bindIp:/bindIp: ${aws_instance.mongo[count.index].private_ip},/' /etc/mongod.conf",
    "sudo systemctl restart mongod",
    "sleep 10",
    "mongo --eval 'rs.initiate({_id: \"rs1\", members: [{_id: 0, host: \"${aws_instance.mongo[0].private_ip}:27017\"}, {_id: 1, host: \"${aws_instance.mongo[1].private_ip}:27017\"}, {_id: 2, host: \"${aws_instance.mongo[2].private_ip}:27017\"}]});'",
   ]
 }
 
 connection {
    type          = "ssh"
    user          = "ubuntu"
    private_key   = tls_private_key.rsa.private_key_pem
    host          = aws_instance.mongo[count.index].private_ip
    bastion_host  = aws_instance.bastion-host.public_ip
    bastion_user  = "ubuntu"
  }
}

