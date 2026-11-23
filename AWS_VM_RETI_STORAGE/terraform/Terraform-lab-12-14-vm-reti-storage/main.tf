terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
}
provider "aws" { region = "us-east-1" }

data "aws_caller_identity" "me" {}
data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}
data "aws_subnet" "az" {
  default_for_az    = true
  availability_zone = "us-east-1a"
}
data "aws_iam_role" "lab" { name = "LabRole" }

# --- Lab 12: istanza + volume dati + snapshot
resource "aws_instance" "web" {
  ami                  = data.aws_ssm_parameter.ami.value
  instance_type        = "t3.micro"
  subnet_id            = data.aws_subnet.az.id
  iam_instance_profile = "LabInstanceProfile"
  monitoring           = false
  tags                 = { Name = "demo-web-01" }
}
resource "aws_ebs_volume" "data" {
  availability_zone = "us-east-1a"
  size              = 2
  type              = "gp3"
  encrypted         = true
  tags              = { Name = "demo-data-vol" }
}
resource "aws_volume_attachment" "data" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.data.id
  instance_id = aws_instance.web.id
}
resource "aws_ebs_snapshot" "data" {
  volume_id  = aws_ebs_volume.data.id
  depends_on = [aws_volume_attachment.data]
  tags       = { Name = "demo-data-snap" }
}

# --- Lab 13: SNS + allarmi
resource "aws_sns_topic" "alarm" { name = "demo-topic-alarm" }
resource "aws_cloudwatch_metric_alarm" "ebs" {
  alarm_name          = "demo-alarm-ebs-queue"
  namespace           = "AWS/EBS"
  metric_name         = "VolumeQueueLength"
  dimensions          = { VolumeId = aws_ebs_volume.data.id }
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  threshold           = 5
  comparison_operator = "GreaterThanThreshold"
  alarm_actions       = [aws_sns_topic.alarm.arn]
}
resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name          = "demo-cpu-alta"
  namespace           = "AWS/EC2"
  metric_name         = "CPUUtilization"
  dimensions          = { InstanceId = aws_instance.web.id }
  statistic           = "Average"
  period              = 300
  evaluation_periods  = 1
  threshold           = 70
  comparison_operator = "GreaterThanThreshold"
  alarm_actions       = [aws_sns_topic.alarm.arn]
}

# --- Lab 14: AWS Backup
resource "aws_backup_vault" "v" { name = "demo-backup-vault" }
resource "aws_backup_plan" "p" {
  name = "demo-backup-plan"
  rule {
    rule_name         = "demo-daily-rule"
    target_vault_name = aws_backup_vault.v.name
    schedule          = "cron(0 5 * * ? *)"
    lifecycle { delete_after = 7 }
  }
}
resource "aws_backup_selection" "s" {
  name         = "demo-assignment-ebs"
  plan_id      = aws_backup_plan.p.id
  iam_role_arn = data.aws_iam_role.lab.arn
  resources    = [aws_ebs_volume.data.arn]
}
output "instance" { value = aws_instance.web.id }
output "volume" { value = aws_ebs_volume.data.id }
