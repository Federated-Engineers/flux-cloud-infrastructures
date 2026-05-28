terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "null_resource" "atlantis_test" {
  triggers = {
    test = "atlantis"
  }
}