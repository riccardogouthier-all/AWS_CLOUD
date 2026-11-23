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

# ============ SICUREZZA - LAB 09: WAF + Secrets Manager ============
resource "aws_wafv2_web_acl" "l09" {
  name  = "sicurezza09-${local.s}"
  scope = "REGIONAL"
  default_action {
    allow {}
  }
  rule {
    name     = "osserva-admin"
    priority = 0
    action {
      count {}
    }
    statement {
      byte_match_statement {
        search_string         = "/admin"
        positional_constraint = "STARTS_WITH"
        field_to_match {
          uri_path {}
        }
        text_transformation {
          priority = 0
          type     = "NONE"
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "osserva-admin"
      sampled_requests_enabled   = true
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "sicurezza09-${local.s}"
    sampled_requests_enabled   = true
  }
}

resource "aws_secretsmanager_secret" "l09" {
  name                    = "sicurezza09/${local.s}"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "l09" {
  secret_id     = aws_secretsmanager_secret.l09.id
  secret_string = jsonencode({ password = "DEMO-NON-VALIDO-v1" })
}

