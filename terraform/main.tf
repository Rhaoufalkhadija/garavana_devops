provider "aws" {
  region = var.aws_region
}

# ── Security Group ──────────────────────────────────────────────────────────
resource "aws_security_group" "k8s_sg" {
  name        = "garavana-k8s-sg"
  description = "Security group pour le cluster Kubernetes Garavana"

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubernetes API
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Jenkins
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Flask App via NodePort
  ingress {
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Communication interne cluster
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "garavana-k8s-sg"
    Project = "garavana"
  }
}

# ── EC2 Master (k8s control plane + Jenkins) ────────────────────────────────
resource "aws_instance" "master" {
  ami                    = var.ami_id
  instance_type = "t3.small"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
  }

  tags = {
    Name    = "garavana-k8s-master"
    Role    = "master"
    Project = "garavana"
  }
}

# ── EC2 Worker (k8s worker node) ─────────────────────────────────────────────
resource "aws_instance" "worker" {
  ami                    = var.ami_id
  instance_type = "t3.small"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]

  root_block_device {
    volume_size = 15
    volume_type = "gp2"
  }

  tags = {
    Name    = "garavana-k8s-worker"
    Role    = "worker"
    Project = "garavana"
  }
}
