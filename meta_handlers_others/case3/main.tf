# variables.tf
variable "region_amis" {
  type = map(string)
  default = {
    "us-east-1" = "ami-12345678"
    "us-west-2" = "ami-87654321"
  }
}

variable "region" {
  type    = string
  default = "us-east-1"
}

# main.tf
provider "aws" {
  region = var.region
}

resource "aws_instance" "example" {
  ami           = var.region_amis[var.region]
  instance_type = "t2.micro"
}
