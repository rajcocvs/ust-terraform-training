terraform {
  backend "s3" {
    bucket         = "ustawstraining" # change this
    key            = "terraform.tfstate"
    region         = "us-east-1"
  }
}