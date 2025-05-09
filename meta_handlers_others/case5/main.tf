# Define a map variable for EC2 instances with instance type and name
variable "ec2_instances" {
  type = map(object({
    instance_type = string
    ami           = string
  }))
  description = "Map of EC2 instances with their details"
  default = {
    "web" = {
      instance_type = "t2.micro"
      ami           = "ami-0c02fb55956c7d316"  # Amazon Linux 2 AMI
    }
    "db" = {
      instance_type = "t2.medium"
      ami           = "ami-0c02fb55956c7d316"  # Amazon Linux 2 AMI
    }
    "app" = {
      instance_type = "t2.small"
      ami           = "ami-0c02fb55956c7d316"  # Amazon Linux 2 AMI
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Create EC2 instances using 'for_each' based on the map variable
resource "aws_instance" "ec2_instances" {
  for_each = var.ec2_instances  # Iterate over the map variable
  
  ami           = each.value.ami           # AMI based on the instance
  instance_type = each.value.instance_type # Instance type based on the instance
  
  tags = {
    Name = each.key  # Set the name of the instance to the key of the map (web, db, app)
  }
}


