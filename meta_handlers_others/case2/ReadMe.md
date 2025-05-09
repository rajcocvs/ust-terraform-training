This Terraform code dynamically provisions multiple subnets across Availability Zones (AZs) within a single VPC in AWS. Here's a breakdown of each part:

✅ variables.tf

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
Explanation:

Declares a variable azs of type list(string).

Default value is a list of 3 Availability Zones in the us-east-1 region.

Used to distribute subnets across multiple AZs for high availability.

✅ main.tf
1. VPC Resource

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}
Explanation:

Creates a VPC with a CIDR block of 10.0.0.0/16, which supports 65,536 IP addresses.

2. Subnet Resource

resource "aws_subnet" "example" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet("10.0.0.0/16", 4, count.index)
  availability_zone = var.azs[count.index]
}
Explanation:

Uses the count meta-argument to create one subnet per AZ.

count = length(var.azs) results in 3 subnets (one for each AZ).

vpc_id = aws_vpc.main.id: Associates each subnet with the VPC.

availability_zone = var.azs[count.index]: Assigns a unique AZ from the list to each subnet.

cidr_block = cidrsubnet("10.0.0.0/16", 4, count.index):

Divides the 10.0.0.0/16 block into smaller /20 blocks (4 extra bits = 2⁴ = 16 subnets).

Picks the count.index-th subnet.

So you get:

Subnet 0 → 10.0.0.0/20

Subnet 1 → 10.0.16.0/20

Subnet 2 → 10.0.32.0/20

🔁 What This Code Does
Provisions 1 VPC.

Inside that VPC, it creates 3 subnets, each:

In a different Availability Zone.

With a non-overlapping CIDR block.