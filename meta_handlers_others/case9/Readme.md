 variable "vpc_cidr" block

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
This defines an input variable named vpc_cidr.

It's of type string, and the default is a Class A private IP range: 10.0.0.0/16.

🔷 aws_vpc resource block

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "main-vpc"
  }
}
This creates a Virtual Private Cloud (VPC) using the CIDR block provided by the variable above.

The VPC will be tagged with the name main-vpc.

🔷 aws_security_group block — Static SG

resource "aws_security_group" "static_sg" {
  name        = "static-sg"
  description = "Security Group without dynamic block"
  vpc_id      = aws_vpc.main.id
This creates a Security Group within the VPC you just created.

It’s named static-sg and is tied to the main VPC by using aws_vpc.main.id.

🔸 ingress rules

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
This allows SSH access (port 22) from anywhere (0.0.0.0/0).

Similarly, you allow HTTP (port 80) and HTTPS (port 443) with the same open policy:


from_port = 80 | 443
⚠️ Allowing access from 0.0.0.0/0 is open to the world — great for testing, but not recommended for production without proper firewalling.

🔸 egress rule

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
This allows all outbound traffic (-1 means any protocol, and ports 0 to 0 cover the full range).

🔸 tags block

  tags = {
    Name = "Static-SG"
  }
Just adds a name tag to the Security Group for easy identification in the AWS Console.

✅ Summary
Your code is correct, production-ready for basic usage, and clearly written.

You are statically defining inbound rules for common ports (SSH, HTTP, HTTPS).

Outbound traffic is fully allowed.

You’re using variable input for CIDR and tagging resources, which is good practice.