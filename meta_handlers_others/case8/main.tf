

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }


}


variable "instance_name" {
  default = "demo-instance"
}
provider "aws" {
  region = "us-east-1"
}


#case1
 variable "create_instance" {
  description = "Flag to control instance creation"
  type        = bool
  default     = true
}
resource "aws_instance" "example1" {
  count         = var.create_instance ? 1 : 0
  ami           = "ami-0c55b159cbfafe1f0" # Replace with a valid AMI
  instance_type = "t2.micro"
  tags = {
    Name = "ConditionalInstance"
  }
}

#case2
variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}
resource "aws_instance" "example2" {
  ami           = "ami-0f88e80871fd81e91" # Replace with a valid AMI
  instance_type = var.environment == "prod" ? "t3.large" : "t3.micro"

  tags = {
    Name = "Instance-${var.environment}"
  }
}


#case3
resource "aws_instance" "example3" {
  count = (var.create_instance && var.environment == "prod") ? 1 : 0

  ami           = "ami-0f88e80871fd81e91"
  instance_type = "t3.large"

  tags = {
    Name = "Conditional-${var.environment}"
  }
}
#case4
locals {
  instance_type = (var.environment == "prod" ? "t3.large" :
                  var.environment == "staging" ? "t3.medium" :
                  "t3.micro")
}

resource "aws_instance" "example4" {
  ami           = "ami-0f88e80871fd81e91"
  instance_type = local.instance_type

  tags = {
    Name = "Instance-${var.environment}"
  }
}
#case5


resource "aws_instance" "example5" {
  count = (var.create_instance && 
          (var.environment == "prod" || var.environment == "dev")) ? 1 : 0

  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.medium"

  tags = {
    Name = "Instance-${var.environment}"
  }
}




 