
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

}

provider "aws" {
  region = "us-east-1"
}
variable "instances" {
  default = {
    web1 = "t2.micro"
    web2 = "t2.medium"
    web3 = "t3.medium"
  }
}

resource "aws_instance" "web" {
  for_each = var.instances

  ami           = "ami-0f88e80871fd81e91"
  instance_type = each.value
  tags = {
    Name = each.key
  }
}

variable "names" {
  default = ["web1", "web2", "web3"]
}

resource "aws_s3_bucket" "buckets" {
  for_each = toset(var.names)

  bucket = "${each.key}-bucket-123"
 
}
