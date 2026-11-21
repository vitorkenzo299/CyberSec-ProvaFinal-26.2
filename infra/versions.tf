terraform {
  backend "s3" {}
  required_version = ">= 1.13.5, < 2.0"
  required_providers {
    aws    = { source = "hashicorp/aws", version = "~> 6.40" }
    random = { source = "hashicorp/random", version = "~> 3.7" }
    time   = { source = "hashicorp/time", version = "~> 0.13" }
  }
}

provider "aws" {
  region              = "us-east-1"
  allowed_account_ids = [var.expected_account_id]
  default_tags {
    tags = { Project = local.name, ManagedBy = "Terraform", Purpose = "AcademicFinal", Environment = "lab" }
  }
}
