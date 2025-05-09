our Terraform code defines IAM Users, IAM Policies, and IAM Roles with different types of policy attachments. Let’s break down each section in detail.

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
This section defines the AWS provider and specifies the version 5.0 or above.

The region is set to us-east-1 for all resources created in this configuration.

2. IAM User Configuration
Create IAM User:

resource "aws_iam_user" "my_user" {
  name = "ustglobal"
}
This resource creates an IAM User with the name ustglobal. This user will have permissions attached via policies later.

Attach Managed Policy to IAM User:

resource "aws_iam_user_policy_attachment" "my_user_managed_policy" {
  user       = aws_iam_user.my_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}
This resource attaches the AmazonS3ReadOnlyAccess managed policy to the IAM user.

The user will have read-only access to Amazon S3.

Inline Policy for IAM User:

resource "aws_iam_user_policy" "my_user_inline_policy" {
  name   = "MyUserInlinePolicy"
  user   = aws_iam_user.my_user.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:ListBucket"
        Effect   = "Allow"
        Resource = "arn:aws:s3:::my-bucket"
      },
      {
        Action   = "s3:GetObject"
        Effect   = "Allow"
        Resource = "arn:aws:s3:::my-bucket/*"
      }
    ]
  })
}
This resource defines an inline policy that grants permissions for the IAM user to list the contents of a specific S3 bucket (my-bucket) and get objects within that bucket.

3. IAM Custom Policy:

resource "aws_iam_policy" "my_policy" {
  name        = "MyPolicy"
  description = "This is my custom policy"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "s3:ListBucket"
        Effect   = "Allow"
        Resource = "arn:aws:s3:::my-bucket"
      },
      {
        Action   = "s3:GetObject"
        Effect   = "Allow"
        Resource = "arn:aws:s3:::my-bucket/*"
      }
    ]
  })
}
This creates a custom IAM policy that grants read access to the same S3 bucket (my-bucket), similar to the inline policy above.

The difference is that this policy can be reused and attached to multiple IAM entities (users, groups, roles) without needing to duplicate it.

4. IAM Role Configuration
Create IAM Role:

resource "aws_iam_role" "my_role" {
  name = "MyRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}
This creates an IAM Role named MyRole and defines an assume role policy.

The assume role policy allows an EC2 instance to assume this role, which means EC2 instances can use this role to gain permissions.

Attach Managed Policy to IAM Role:

resource "aws_iam_role_policy_attachment" "my_role_managed_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
  role       = aws_iam_role.my_role.name
}
This attaches the AmazonEC2ReadOnlyAccess managed policy to the MyRole role.

This grants read-only access to EC2 resources for any entity that assumes this role (like an EC2 instance).

Attach Custom Policy to IAM Role:

resource "aws_iam_role_policy_attachment" "my_role_custom_policy" {
  policy_arn = aws_iam_policy.my_policy.arn
  role       = aws_iam_role.my_role.name
}
This attaches the custom IAM policy (my_policy) created earlier to the IAM role MyRole.

This provides the role with read access to S3 resources as defined in the custom policy.

Inline Policy for IAM Role:

resource "aws_iam_role_policy" "my_role_inline_policy" {
  name = "MyRoleInlinePolicy"
  role = aws_iam_role.my_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["ec2:DescribeInstances"]
        Effect   = "Allow"
        Resource = "*"
      },
      {
        Action   = ["s3:ListAllMyBuckets"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
This creates an inline policy for the IAM role MyRole.

The inline policy grants permissions to describe EC2 instances and list all S3 buckets.

Summary of Key Points
IAM User:

Created with a name ustglobal.

Has a managed policy (AmazonS3ReadOnlyAccess) for read-only S3 access.

Also has an inline policy for more granular access to a specific S3 bucket (my-bucket).

IAM Policy:

A custom policy granting access to my-bucket is created and can be attached to multiple IAM entities (users, roles).

IAM Role:

Created with an assume role policy that allows EC2 to assume the role.

Managed policies for EC2 read-only access and custom policies for S3 read access are attached to the role.

An inline policy for EC2 instance description and listing S3 buckets is also attached.