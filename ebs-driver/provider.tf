terraform {
  required_providers {
    aws = {
      source         = "hashicorp/aws"
      version        = "4.19.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region             = var.region
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}