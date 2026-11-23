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

# ============ SICUREZZA - LAB 08: allarme CloudWatch ============
resource "aws_cloudwatch_metric_alarm" "l08" {
  alarm_name          = "sicurezza08-${local.s}"
  namespace           = "Sicurezza08"
  metric_name         = "ErroriAccesso"
  dimensions          = { Studente = local.s }
  statistic           = "Sum"
  period              = 60
  evaluation_periods  = 1
  threshold           = 3
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "missing"
  actions_enabled     = false
}

