
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.31.0" # AWS provider version, not terraform version
    }
  }

  backend "s3" { 
     bucket = "roboshopteraform"
     key    = "K8s_sg"
     region = "us-east-1"
     dynamodb_table = "roboshopteraform" 
  }
}

provider "aws" {
  region = "us-east-1"
}