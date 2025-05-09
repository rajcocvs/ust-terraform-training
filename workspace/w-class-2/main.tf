

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

variable "my_instance" {
    type = string
  
}

resource "aws_instance" "instance1" {
    ami="ami-0f88e80871fd81e91"
    instance_type = var.my_instance
    tags = {
      Name = terraform.workspace
    }
    
  }
   resource "aws_instance" "instance" {
    ami="ami-0f88e80871fd81e91"
    instance_type = terraform.workspace =="dev" ? "t2.micro":"t2.medium"
    tags = {
      Name = "sample"
    } 
    
  }