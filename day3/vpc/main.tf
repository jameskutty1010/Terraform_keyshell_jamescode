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

// VPC

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "test-vpc"

  }
}

// PUBLIC SUBNETS

resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.0.0/18"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2a"
 tags = {
    Name = "test-public-subnet-1"

  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.64.0/18"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-2b"
 tags = {
    Name = "test-public-subnet-2"

  }
}

//PRIVATE SUBNET

resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.128.0/18"
  availability_zone       = "us-east-2a"
 tags = {
    Name = "test-private-subnet-1"

  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.192.0/18"
  availability_zone       = "us-east-2b"
 tags = {
    Name = "test-private-subnet-2"

  }
}

// IGW

resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "test-igw"

  }
}


// NAT

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id
  tags = {
    Name = "test-nat"
  }
}

// EIP

resource "aws_eip" "nat_eip" {
  vpc        = true
   tags = {
    Name        = "test-eip"

  }
}

// Security

resource "aws_security_group" "my-sec" {
  vpc_id =  aws_vpc.vpc.id
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
}

resource "aws_instance" "web" {
  ami                    = "ami-0ccabb5f82d4c9af5"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.my-sec.id]
  subnet_id     = aws_subnet.public_subnet_1.id
  key_name               = aws_key_pair.webserver-key.key_name
  user_data              = file("install_apache.sh")
  tags = {
    Name = "web"
  }
}


