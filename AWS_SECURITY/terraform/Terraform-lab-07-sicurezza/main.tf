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

# ============ SICUREZZA - LAB 07: log group ============
resource "aws_cloudwatch_log_group" "l07" {
  name = "/sicurezza07/${local.s}"
}

