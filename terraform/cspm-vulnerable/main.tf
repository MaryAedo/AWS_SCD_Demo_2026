terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# ------------------------------------------------------------------
# CSPM Issue 1 y 2: S3 inseguro (acceso público + sin cifrado)
# ------------------------------------------------------------------
resource "aws_s3_bucket" "insecure_bucket" {
  bucket_prefix = "devsecops-demo-lab-"

  tags = {
    Environment = "StudentCommunityDay"
    Compliance  = "Non-Compliant-Demo"
  }
}

# CSPM Issue 1: [S3.1] S3 Block Public Access setting should be enabled
resource "aws_s3_bucket_public_access_block" "bad_block" {
  bucket = aws_s3_bucket.insecure_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# CSPM Issue 2: [S3.4] No se define una configuración de cifrado del bucket.

# ------------------------------------------------------------------
# CSPM Issue 3: [EC2.8] Security Group con SSH abierto a Internet
# ------------------------------------------------------------------
resource "aws_security_group" "bad_sg" {
  name_prefix = "demo-open-ssh-"
  description = "Security Group con puerto 22 expuesto para alerta CSPM"

  ingress {
    description = "SSH abierto al mundo"
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
    Name = "demo-insecure-ssh-sg"
  }
}
