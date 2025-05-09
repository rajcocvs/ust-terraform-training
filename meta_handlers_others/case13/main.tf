terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
 
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
 
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
 
  owners = ["137112412989"] # Amazon
}
 
resource "aws_instance" "tf_instance" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = "t2.micro"
  tags = {
    Name = "tf_instance"
  }
}