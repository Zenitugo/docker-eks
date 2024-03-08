terraform {
  required_providers {
    aws = {
      source         = "hashicorp/aws"
      version        = "4.19.0"
    }
  }

  backend "s3" {
    bucket           = "ruby2116"
    key              = "care-key"
    region           = "eu-west-1"
    dynamodb_table   = "rubysapphire234"
  }
  
}

provider "aws" {
  # Configuration options
  region             = var.region
}