This Terraform configuration efficiently launches multiple EC2 instances using a map of objects and the for_each construct. Here's a detailed breakdown:

✅ variables.tf – EC2 Map Variable

variable "ec2_instances" {
  type = map(object({
    instance_type = string
    ami           = string
  }))
  description = "Map of EC2 instances with their details"
  default = {
    "web" = {
      instance_type = "t2.micro"
      ami           = "ami-0c02fb55956c7d316"
    }
    "db" = {
      instance_type = "t2.medium"
      ami           = "ami-0c02fb55956c7d316"
    }
    "app" = {
      instance_type = "t2.small"
      ami           = "ami-0c02fb55956c7d316"
    }
  }
}
🔍 Explanation:
A map of objects defines EC2 instance configurations.

Each key (web, db, app) is a unique identifier.

Each object includes:

instance_type (like t2.micro)

ami ID (Amazon Linux 2)

✅ main.tf – AWS Provider

provider "aws" {
  region = "us-east-1"
}
Sets the AWS region where the EC2 instances will be created.

✅ main.tf – EC2 Instances with for_each

resource "aws_instance" "ec2_instances" {
  for_each = var.ec2_instances

  ami           = each.value.ami
  instance_type = each.value.instance_type

  tags = {
    Name = each.key
  }
}
🔍 Explanation:
Uses for_each to iterate over the map and create one EC2 instance per entry.

each.key is the name (web, db, app) used for tagging.

each.value refers to the actual object (instance_type, ami) from the map.

Output: 3 EC2 instances with respective names and types.

🔧 Benefits of this Approach:
Feature	Benefit
Reusable	Easily add/remove instances by editing the map.
Clean Code	No need to copy-paste multiple aws_instance blocks.
Scalable	Works well for a large number of similar resources.
Dynamic Tags	Sets name tags automatically based on the map key.