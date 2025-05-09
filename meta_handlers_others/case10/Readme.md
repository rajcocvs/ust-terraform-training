Terraform code creates a VPC and a Security Group with dynamic ingress rules. Here's a detailed explanation of what each part of your code does:

1. Terraform Provider Setup

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
This section configures the AWS provider to use the HashiCorp AWS provider version 5.0 or above and specifies the AWS region as us-east-1.

2. Input Variables
vpc_cidr

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
This defines the CIDR block for the VPC (10.0.0.0/16), which is a private IP range for internal networking within the VPC.

ingress_ports

variable "ingress_ports" {
  description = "List of ingress ports to allow"
  type        = list(number)
  default     = [22, 80, 443]  # Ports for SSH, HTTP, and HTTPS
}
This defines a list of ports for ingress rules: 22 (SSH), 80 (HTTP), and 443 (HTTPS). You use this list for dynamic ingress rule creation in the security group.

3. VPC Creation

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "main-vpc"
  }
}
This creates a VPC using the CIDR block from the vpc_cidr variable.

The VPC is tagged as "main-vpc".

4. Security Group with Dynamic Ingress

resource "aws_security_group" "dynamic_sg" {
  name        = "dynamic-sg"
  description = "Security Group with dynamic block"
  vpc_id      = aws_vpc.main.id
This creates a Security Group named dynamic-sg in the VPC created above.

Dynamic Ingress Rules

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
The dynamic block is used to generate ingress rules dynamically.

The for_each iterates over the ingress_ports variable, so it creates an ingress rule for each port in the list (22, 80, 443).

For each ingress.value (i.e., each port), it creates a rule allowing TCP traffic from any IP address (0.0.0.0/0) on that port.

Egress Rule

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
The egress rule allows all outbound traffic (any protocol, any port, to any destination IP).

Tags

  tags = {
    Name = "Dynamic-SG"
  }
}
The Security Group is tagged with "Dynamic-SG" for identification purposes in the AWS Console.

✅ Summary
VPC Creation: You are creating a VPC with the CIDR block 10.0.0.0/16.

Security Group: You are using a dynamic block to create ingress rules for a list of ports (22, 80, and 443). This makes your code more flexible as you can easily modify the list of ports in the ingress_ports variable.

Egress Rule: You’re allowing all outbound traffic from the instances associated with this Security Group.

Tags: Both the VPC and Security Group have name tags, making them easier to identify in the AWS console.