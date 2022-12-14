terraform {
  required_providers {
    # https://registry.terraform.io/providers/hashicorp/aws/latest
    aws = {
      source = "hashicorp/aws"
      # https://jubianchi.github.io/semver-check/#/~%3E%204.31/4.34
      # >= 4.31.0 <5.0.0
      version = "~> 4.31"
    }

    # https://registry.terraform.io/providers/hashicorp/null/latest
    null = {
      source = "hashicorp/null"
      # https://jubianchi.github.io/semver-check/#/~%3E%203.1/3.4
      # >= 3.1.0 <4.0.0
      version = "~> 3.1"
    }
  }
}

provider "aws" {
  region = var.region
}