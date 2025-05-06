#create custom vpc and subnets
#launch instances int eh subnets with security groups and NACls (Network Access Control List)

terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version="~>5.0"
    }
  }
}


provider "aws" {
    region = "us-east-1"
}

#VPC

resource "aws_vpc" "UST-A-VPC" {
    cidr_block = "192.168.0.0/24"
    tags = {
        Name = "UST-A-VPC-tag"
    }
}

#Internet Gateway

resource "aws_internet_gateway" "UST-IGW" {
    vpc_id = aws_vpc.UST-A-VPC.id
    tags = {
      Name = "UST-IGW-tag"
    }
}
#Public Subnet

resource "aws_subnet" "UST-A-PubSub" {
    vpc_id = aws_vpc.UST-A-VPC.id
    cidr_block = "192.168.0.0/25"
    # map_customer_owned_ip_on_launch = true
    availability_zone = "us-east-1a"
    tags = {
      Name = "UST-A-PubSub-tag"
    }
}

resource "aws_subnet" "UST-A-PriSub" {
  vpc_id = aws_vpc.UST-A-VPC.id
  cidr_block = "192.168.0.128/25"
  availability_zone = "us-east-1b"
  tags = {
      Name = "UST-A-PriSub-tag"
    }
}

# Route table for PubSub
resource "aws_route_table" "UST-A-PubSub-RT" {
    vpc_id = aws_vpc.UST-A-VPC.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.UST-IGW.id
    }
    tags = {
      Name = "UST-A-PubSub-RT-tag"
    }
}

#Route table for PriSub
resource "aws_route_table" "UST-A-PriSub-RT" {
    vpc_id = aws_vpc.UST-A-VPC.id
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.UST-A-VPC-NATGW.id
    }
    tags = {
      Name = "UST-A-PriSub-RT-tag"
    }
}

#PubSub Route table association
resource "aws_route_table_association" "PubSub-RT-Assoc" {
  subnet_id = aws_subnet.UST-A-PubSub.id
  route_table_id = aws_route_table.UST-A-PubSub-RT.id
}

#PriSub Route table association
resource "aws_route_table_association" "PriSub-RT-Assoc" {
    subnet_id = aws_subnet.UST-A-PriSub.id
    route_table_id = aws_route_table.UST-A-PriSub-RT.id
}

#Elastic IP for NAT gateway
resource "aws_eip" "eip-NAT-GW" {
    domain = "vpc"
}

#NAT Gateway
resource "aws_nat_gateway" "UST-A-VPC-NATGW" {
    allocation_id = aws_eip.eip-NAT-GW.id
    subnet_id = aws_subnet.UST-A-PubSub.id
    tags = {
      Name = "UST-A-VPC-NATGW-tag"
    }
}

#Security group
resource "aws_security_group" "UST-A-SG" {
  name = "UST-A-SG"
  description = "Allow SSH and HTTP"
  vpc_id = aws_vpc.UST-A-VPC.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#NACL
resource "aws_network_acl" "UST-A-VPC-NACL" {
    vpc_id = aws_vpc.UST-A-VPC.id

    ingress {
        protocol = "-1"
        rule_no = 100
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }

    egress {
        protocol = "-1"
        rule_no = 100
        action = "allow"
        cidr_block = "0.0.0.0/0"
        from_port = 0
        to_port = 0
    }
}

#NACL association with PubSub
resource "aws_network_acl_association" "NACL-PubSub" {
  subnet_id = aws_subnet.UST-A-PubSub.id
  network_acl_id = aws_network_acl.UST-A-VPC-NACL.id
}

#NACL association with PriSub
resource "aws_network_acl_association" "NACL-PriSub" {
    subnet_id = aws_subnet.UST-A-PriSub.id
    network_acl_id = aws_network_acl.UST-A-VPC-NACL.id
}

#EC2 Public 
resource "aws_instance" "UST-A-VPC-Public-EC2" {
    ami = "ami-0f88e80871fd81e91"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.UST-A-PubSub.id
    vpc_security_group_ids = [aws_security_group.UST-A-SG.id]
    associate_public_ip_address = true
    user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<html><body><h1>This is your Public Instance from Custom VPC UST-A-VPC</h1></body></html>" > /var/www/html/index.html
              EOF
    tags = {
      Name = "UST-A-Public-EC2"
    }
}

#EC2 Private

resource "aws_instance" "UST-A-VPC-Private-EC2" {
    ami = "ami-0f88e80871fd81e91"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.UST-A-PriSub.id
    vpc_security_group_ids = [aws_security_group.UST-A-SG.id]
    tags = {
      Name = "UST-A-Private-EC2"
    }
}


output "public_ec2_public_ip" {
  value = aws_instance.UST-A-VPC-Public-EC2.public_ip
}

output "public_ec2_private_ip" {
  value = aws_instance.UST-A-VPC-Public-EC2.private_ip
}

output "private_ec2_instance_id" {
  value = aws_instance.UST-A-VPC-Private-EC2.id
}

output "private_ec2_name" {
  value = aws_instance.UST-A-VPC-Private-EC2.tags["Name"]
}

output "private_ec2_private_ip" {
  value = aws_instance.UST-A-VPC-Private-EC2.private_ip
}
