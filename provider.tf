terraform {
    required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
    required_version = ">= 1.2.0"

    backend "s3" {
        bucket = "bucket-s3-dom"
        key = "terraform.tfstate"
        region = "us-east-1"
    }
}

provider "aws" {
  region = var.region
}