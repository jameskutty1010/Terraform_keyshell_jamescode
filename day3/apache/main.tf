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

// Security

resource "aws_security_group" "my-sec" {
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "test-sg"
  }
}
// Key

resource "aws_key_pair" "webserver-key" {
  key_name   = "webserver-key"
  public_key = file("~/.ssh/id_rsa.pub")
  #provider   = aws.oregon
}

resource "aws_instance" "web" {
  ami                    = "ami-0ccabb5f82d4c9af5"
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.my-sec.id]
  key_name               = aws_key_pair.webserver-key.key_name
  user_data              = file("install_apache.sh")
  tags = {
    Name = "web"
  }
}
