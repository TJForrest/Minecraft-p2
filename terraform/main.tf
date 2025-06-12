# Terraform setup 
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

# AWS credentials 
provider "aws" {
  region                   = "us-west-2"
  shared_credentials_files = ["/home/flynn/school/cs_312/Minecraft-p2/creds"]
  profile                  = "default"
}

# Key pair sharing
resource "aws_key_pair" "minecraft" {
  key_name   = "minecraft-key"
  public_key = file("/home/flynn/school/cs_312/Minecraft-p2/keys/minecraft-key.pub")
}

# Security group set up
resource "aws_security_group" "minecraft_sec_group" {
  name        = "minecraft-security_group"
  description = "Allow Minecraft and SSH access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Instance
resource "aws_instance" "app_server" {
  ami                    = "ami-00565a15a71e4402a"
  instance_type          = "t4g.small"
  key_name               = aws_key_pair.minecraft.key_name
  vpc_security_group_ids = [aws_security_group.minecraft_sec_group.id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name = "Minecraft Server"
  }
}
