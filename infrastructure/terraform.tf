terraform {
  cloud {
    organization = "AE-TECH"

    workspaces {
      name = "learn-terraform"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region

  /* 
  access_key = "my-access-key"
  secret_key = "my-secret-key" 
  //*/

  default_tags {
    tags = {
      HashiCorpLAMPStack = "terraform-aws-lamp-stack"
    }
  }
}

provider "random" {}

