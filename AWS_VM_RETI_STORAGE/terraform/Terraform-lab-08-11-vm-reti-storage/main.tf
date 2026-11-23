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

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# ============ VM-STORAGE - LAB 08/09: S3 ============
# ============ VM-STORAGE - rete demo-vpc (Lab 10/11) ============
resource "aws_vpc" "demo" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "demo-vpc" }
}

resource "aws_internet_gateway" "demo" {
  vpc_id = aws_vpc.demo.id
  tags   = { Name = "demo-igw" }
}

resource "aws_subnet" "web" {
  vpc_id                  = aws_vpc.demo.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags                    = { Name = "demo-subnet-web" }
}

resource "aws_subnet" "web2" {
  vpc_id                  = aws_vpc.demo.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags                    = { Name = "demo-subnet-web-b" }
}

resource "aws_subnet" "app" {
  vpc_id            = aws_vpc.demo.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags              = { Name = "demo-subnet-app" }
}

resource "aws_subnet" "db" {
  vpc_id            = aws_vpc.demo.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags              = { Name = "demo-subnet-db" }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.demo.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo.id
  }
  tags = { Name = "demo-rt-public" }
}

resource "aws_route_table_association" "web" {
  subnet_id      = aws_subnet.web.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "web2" {
  subnet_id      = aws_subnet.web2.id
  route_table_id = aws_route_table.public.id
}

# ---- Security Group Lab 11 (catena ALB -> web -> app -> db) ----
resource "aws_security_group" "alb" {
  name        = "demo-sg-tier-alb"
  description = "Gruppo ingresso pianificato (nessun ALB associato)"
  vpc_id      = aws_vpc.demo.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "demo-sg-tier-alb" }
}

resource "aws_security_group" "tier_web" {
  name        = "demo-sg-tier-web"
  description = "Livello web"
  vpc_id      = aws_vpc.demo.id
  ingress {
    description     = "HTTP dal SG ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  tags = { Name = "demo-sg-tier-web" }
}

resource "aws_security_group" "tier_app" {
  name        = "demo-sg-tier-app"
  description = "Livello application"
  vpc_id      = aws_vpc.demo.id
  ingress {
    description     = "TCP 8080 dal SG web"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.tier_web.id]
  }
  tags = { Name = "demo-sg-tier-app" }
}

resource "aws_security_group" "tier_db" {
  name        = "demo-sg-tier-db"
  description = "Livello database"
  vpc_id      = aws_vpc.demo.id
  ingress {
    description     = "MySQL dal SG app"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.tier_app.id]
  }
  tags = { Name = "demo-sg-tier-db" }
}

# ---- VPN dimostrativa Lab 11 ----
resource "aws_vpn_gateway" "vgw" {
  vpc_id = aws_vpc.demo.id
  tags   = { Name = "demo-vgw" }
}

# ---- Lab 09: volume EBS cifrato ----
resource "aws_ebs_volume" "enc" {
  availability_zone = "us-east-1a"
  size              = 10
  type              = "gp3"
  encrypted         = true
  tags              = { Name = "demo-encrypted-vol" }
}

# ---- Lab 10: EC2 + EBS + EFS ----
resource "aws_security_group" "inst" {
  name        = "demo-sg-instances"
  description = "Istanze applicative demo"
  vpc_id      = aws_vpc.demo.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "demo-sg-instances" }
}

resource "aws_security_group" "efs" {
  name        = "demo-sg-efs"
  description = "NFS 2049 dalle istanze applicative"
  vpc_id      = aws_vpc.demo.id
  ingress {
    description     = "NFS dal SG istanze"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.inst.id]
  }
  tags = { Name = "demo-sg-efs" }
}

resource "aws_efs_file_system" "shared" {
  performance_mode = "generalPurpose"
  tags             = { Name = "demo-efs-shared" }
}

resource "aws_efs_mount_target" "a" {
  file_system_id  = aws_efs_file_system.shared.id
  subnet_id       = aws_subnet.web.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_efs_mount_target" "b" {
  file_system_id  = aws_efs_file_system.shared.id
  subnet_id       = aws_subnet.web2.id
  security_groups = [aws_security_group.efs.id]
}

resource "aws_instance" "web01" {
  ami                    = data.aws_ssm_parameter.al2023.value
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.web.id
  vpc_security_group_ids = [aws_security_group.inst.id]
  iam_instance_profile   = "LabInstanceProfile"
  user_data              = <<-EOT
    #!/bin/bash
    dnf install -y amazon-efs-utils
    mkdir -p /mnt/efs-shared
    for i in $(seq 1 30); do mount -t efs -o tls ${aws_efs_file_system.shared.id}:/ /mnt/efs-shared && break; sleep 10; done
  EOT
  tags                   = { Name = "demo-web-01" }
  depends_on             = [aws_efs_mount_target.a, aws_efs_mount_target.b, aws_internet_gateway.demo]
}

resource "aws_instance" "web02" {
  ami                    = data.aws_ssm_parameter.al2023.value
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.web2.id
  vpc_security_group_ids = [aws_security_group.inst.id]
  iam_instance_profile   = "LabInstanceProfile"
  user_data              = <<-EOT
    #!/bin/bash
    dnf install -y amazon-efs-utils
    mkdir -p /mnt/efs-shared
    for i in $(seq 1 30); do mount -t efs -o tls ${aws_efs_file_system.shared.id}:/ /mnt/efs-shared && break; sleep 10; done
  EOT
  tags                   = { Name = "demo-web-02" }
  depends_on             = [aws_efs_mount_target.a, aws_efs_mount_target.b, aws_internet_gateway.demo]
}

resource "aws_ebs_volume" "data01" {
  availability_zone = "us-east-1a"
  size              = 10
  type              = "gp3"
  tags              = { Name = "demo-data-vol" }
}

resource "aws_ebs_volume" "data02" {
  availability_zone = "us-east-1b"
  size              = 10
  type              = "gp3"
  tags              = { Name = "demo-data-vol-02" }
}

resource "aws_volume_attachment" "data01" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.data01.id
  instance_id = aws_instance.web01.id
}

resource "aws_volume_attachment" "data02" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.data02.id
  instance_id = aws_instance.web02.id
}

output "efs_id" { value = aws_efs_file_system.shared.id }
output "web01" { value = aws_instance.web01.id }
output "web02" { value = aws_instance.web02.id }
