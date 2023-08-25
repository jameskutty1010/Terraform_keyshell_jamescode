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


resource "aws_instance" "app_server" {
  ami           = "ami-0ccabb5f82d4c9af5"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

resource "aws_iam_user" "name" {
  name = var.name
}

variable "name" {
 default = "user1"
}

resource "aws_s3_bucket" "example" {
  bucket = "my-tf-test-bucket564"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
