# variables.tf
variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

# main.tf
resource "aws_subnet" "example" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet("10.0.0.0/16", 4, count.index)
  availability_zone = var.azs[count.index]
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

