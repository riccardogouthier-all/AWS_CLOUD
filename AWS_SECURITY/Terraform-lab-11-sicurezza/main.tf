terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "aws_ebs_volume" "origine" {
  availability_zone = "us-east-1a"
  size              = 1
  type              = "gp3"
  encrypted         = true
  tags              = { Name = "sicurezza11-rg" }
}

resource "aws_backup_vault" "lab" {
  name = "sicurezza11-rg"
}

output "volume_id" { value = aws_ebs_volume.origine.id }
output "volume_arn" { value = aws_ebs_volume.origine.arn }
