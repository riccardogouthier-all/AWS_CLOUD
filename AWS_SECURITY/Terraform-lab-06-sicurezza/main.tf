terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" {
  region = "us-east-1"
}

locals {
  s = "rg" # SUFFISSO (iniziali)
}

# ============ SICUREZZA - LAB 06: VPC e filtri di rete ============
resource "aws_vpc" "l06" {
  cidr_block = "10.60.0.0/16"
  tags       = { Name = "sicurezza06-${local.s}" }
}

resource "aws_subnet" "l06" {
  vpc_id                  = aws_vpc.l06.id
  cidr_block              = "10.60.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
  tags                    = { Name = "sicurezza06-${local.s}-subnet" }
}

resource "aws_security_group" "l06" {
  name        = "sicurezza06-${local.s}-sg"
  description = "Lab06 HTTPS da client aziendale"
  vpc_id      = aws_vpc.l06.id
  ingress {
    description = "HTTPS da 10.20.1.0/24"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.20.1.0/24"]
  }
  egress = [] # regola outbound generale rimossa
  tags   = { Name = "sicurezza06-${local.s}-sg" }
}

resource "aws_network_acl" "l06" {
  vpc_id     = aws_vpc.l06.id
  subnet_ids = [aws_subnet.l06.id]
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "10.20.1.0/24"
    from_port  = 443
    to_port    = 443
  }
  egress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "10.20.1.0/24"
    from_port  = 1024
    to_port    = 65535
  }
  tags = { Name = "sicurezza06-${local.s}-nacl" }
}

