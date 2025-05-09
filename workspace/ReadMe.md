>>A Terraform Workspace is a way to manage multiple state files within the same Terraform configuration directory. Each workspace has its own state file, allowing you to reuse the same configuration for different environments (like dev, staging, and prod) without duplicating code.

>>Basic Commands

terraform workspace list              # Lists all workspaces
terraform workspace new dev          # Creates 'dev' workspace
terraform workspace select dev       # Switches to 'dev' workspace
terraform workspace show             # Shows current workspace
terraform apply 

>>Sample Scenarios:

sample 1:Real-Time Scenario: Deploying Infrastructure in Dev, Staging, and Prod
Suppose you manage:

VPC

EC2

RDS

You want the same setup in:

Dev (smaller EC2)

Staging (medium EC2)

Prod (large EC2)

Instead of copying code for each environment, you use workspaces with a single Terraform configuration and use variables that change per workspace.





HYPOSTHIS FOR DISCUSSION:
If your goal is to create multiple environments at once, use one workspace and loop in code instead:  

Looping Without Workspaces (No Isolation):
variable "environments" {
  type = list(string)
  default = ["dev", "staging", "prod"]
}

resource "aws_instance" "per_env" {
  count         = length(var.environments)
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  tags = {
    Name = var.environments[count.index]
  }
}

But this loses the state isolation benefit of workspaces.


When You Loop Over Resources in a Single Workspace
You lose state isolation because everything is deployed and tracked in a single terraform.tfstate file. This means:
| **Aspect**                     | **Looping in Single Workspace**              | **Using Workspaces**                                           |
| -------------------------------------------------------------- |
| **State File**                 | One state file for all environments          | Separate state file per workspace                              |
| **Risk of Accidental Changes** | High — a mistake can affect all environments | Low — mistakes affect only the selected workspace              |
| **Granular Destroy**           | No — destroys everything at once             | Yes — can destroy resources in just one workspace              |
| **Deployment Control**         | All environments deployed at once            | Environments deployed one at a time                            |
| **State Location**             | `.terraform/terraform.tfstate`               | `.terraform/terraform.tfstate.d/<workspace>/terraform.tfstate` |



Scenarios 2: Scenario: Provisioning S3 Buckets for Dev, Staging, and Prod
You want to provision a uniquely named S3 bucket for:

Development (logs-dev-bucket)

Staging (logs-staging-bucket)

Production (logs-prod-bucket)


Looping Without Workspaces (No Isolation):



variable "environments" {
  type    = list(string)
  default = ["dev", "staging", "prod"]
}

resource "aws_s3_bucket" "logs" {
  count  = length(var.environments)
  bucket = "logs-${var.environments[count.index]}-bucket"
  acl    = "private"
}

