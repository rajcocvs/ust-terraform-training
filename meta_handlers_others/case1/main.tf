# variables.tf
variable "region" {
  type    = string
  default = "us-east-1"
}

# main.tf
provider "aws" {
  region = var.region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}
