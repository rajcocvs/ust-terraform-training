This Terraform configuration defines a basic setup to create an Amazon VPC (Virtual Private Cloud) in the AWS Cloud. Here's a breakdown of the files and their content:



variable "region" {
  type    = string
  default = "us-east-1"
}
Explanation:

This declares a Terraform input variable named region.

It is of type string.

It has a default value: "us-east-1" (AWS US East (N. Virginia) region).

This makes the region easily configurable without hardcoding it in multiple places.

✅ main.tf

provider "aws" {
  region = var.region
}
Explanation:

This block configures the AWS provider, which tells Terraform to use AWS as the cloud provider.

It uses the region variable (var.region) defined in variables.tf to set the AWS region.

This is required for any AWS resource creation.


resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}
Explanation:

This block defines an AWS VPC resource named "main".

cidr_block = "10.0.0.0/16" specifies the IP address range for the VPC, allowing up to 65,536 IP addresses.

The tags block assigns a name "main-vpc" to the VPC, which helps identify it in the AWS console.

🔁 Execution Flow Summary
Terraform reads variables.tf and loads the region variable.

Terraform configures the AWS provider to use that region.

Terraform creates a VPC with the CIDR block 10.0.0.0/16.

The VPC is tagged as main-vpc for easy identification.

