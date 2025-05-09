
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

# Locals block for reuse
locals {
  project     = "myapp"
  environment = "dev"
  cidr_block  = "10.0.0.0/16"

  public_subnets = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  tags = {
    Project     = local.project
    Environment = local.environment
  }
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = local.cidr_block

  tags = merge(local.tags, {
    Name = "${local.project}-${local.environment}-vpc"
  })
}

# Subnets (using for_each for reusability)
resource "aws_subnet" "public" {
  for_each = toset(local.public_subnets)

  vpc_id     = aws_vpc.main.id
  cidr_block = each.value
  availability_zone = "us-east-1a"

  tags = merge(local.tags, {
    Name = "${local.project}-${local.environment}-subnet-${each.value}"
  })
}
