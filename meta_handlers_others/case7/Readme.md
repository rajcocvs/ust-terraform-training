This Terraform configuration sets up a reusable and tag-driven AWS VPC environment using the locals block to centralize values for easy modification and maintainability.

✅ Key Components & Explanation:
1. Terraform & Provider Block

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
Declares the AWS provider version (~> 4.0) and sets the region to us-east-1.

2. Local Variables Block

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
Purpose: Centralizes repeated values for better reusability and scalability.

project, environment: Used in naming and tags.

cidr_block: CIDR for the VPC.

public_subnets: A list of subnet CIDRs.

tags: Common tags applied to all resources.

3. VPC Resource

resource "aws_vpc" "main" {
  cidr_block = local.cidr_block

  tags = merge(local.tags, {
    Name = "${local.project}-${local.environment}-vpc"
  })
}
Creates a VPC with the CIDR block 10.0.0.0/16.

Tags:

Adds standard tags (Project, Environment) from locals.tags.

Adds a custom Name tag like myapp-dev-vpc.

4. Subnets (with for_each)

resource "aws_subnet" "public" {
  for_each = toset(local.public_subnets)

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = "us-east-1a"

  tags = merge(local.tags, {
    Name = "${local.project}-${local.environment}-subnet-${each.value}"
  })
}
Uses for_each to dynamically create subnets from the list in local.public_subnets.

All subnets use the same availability zone (us-east-1a).

Subnet names are dynamically generated (e.g., myapp-dev-subnet-10.0.1.0/24).

📌 Summary:
Resource	Count	Notes
aws_vpc.main	1	Main VPC
aws_subnet.public	2	One for each CIDR in public_subnets

🧠 Best Practices Demonstrated:
Use of locals for consistency and reusability.

Dynamic resource creation with for_each.

Tag standardization.

Readable and maintainable structure.