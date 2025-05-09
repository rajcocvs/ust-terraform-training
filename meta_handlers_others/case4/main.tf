# Define a tuple for a MySQL database configuration
variable "mysql_config" {
  type    = tuple([string, number, bool])
  default = ["db.t3.micro", 3, false]  # instance type, replication factor, monitoring flag
}

provider "aws" {
  region = "us-east-1"
}

# Output the MySQL instance configuration details
output "mysql_config" {
  value = {
    instance_type   = var.mysql_config[0]    # DB instance type
    replication_factor = var.mysql_config[1]  # Number of replicas
    enable_monitoring = var.mysql_config[2]   # Monitoring flag
  }
}

# Create an RDS instance using the tuple values
resource "aws_db_instance" "mysql_db" {
  allocated_storage    = 20
  storage_type         = "gp2"
  instance_class       = var.mysql_config[0]  # Use the instance type from the tuple
  engine               = "mysql"
  engine_version       = "8.0"
  username             = "admin"
  password             = "password123"
  db_name              = "mydb"
  multi_az             = var.mysql_config[2]  # Use the monitoring flag for multi-az
  availability_zone    = "us-east-1a"
  publicly_accessible  = false
}
