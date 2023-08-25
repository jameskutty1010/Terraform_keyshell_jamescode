terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-2"
}

data "aws_instance" "existing_instance" {
  instance_id = "i-089bb9bb5cc95d8a9"  # Replace with the actual instance ID
}

output "instance_public_ip" {
  value = data.aws_instance.existing_instance.public_ip
}
