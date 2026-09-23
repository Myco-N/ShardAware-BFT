# Terraform skeleton for 20 × c5.4xlarge (ICSOC 2026 Artifact)
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

variable "region" {
  default = "us-east-1"
}

variable "instance_count" {
  default = 20
}

resource "aws_instance" "validator" {
  count         = var.instance_count
  ami           = "ami-0c7217cdde317cf88" # Ubuntu 22.04 example
  instance_type = "c5.4xlarge"
  tags = {
    Name = "icsoc2026-validator-${count.index}"
    Project = "ICSOC2026-Artifact"
  }
}

output "instance_ips" {
  value = aws_instance.validator[*].public_ip
}
