

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }


}


variable "instance_name" {
  default = "demo-instance"
}
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "demo" {
  ami           = "ami-0f88e80871fd81e91" # Amazon Linux 2 AMI in us-east-1
  instance_type = "t2.micro"
  tags = {
    Name = var.instance_name
  }

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = true
    ignore_changes        = [tags]
  }
}
