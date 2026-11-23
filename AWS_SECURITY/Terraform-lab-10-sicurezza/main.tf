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

# ============ SICUREZZA - LAB 10: GuardDuty ============
resource "aws_guardduty_detector" "l10" {
  enable = true
}

