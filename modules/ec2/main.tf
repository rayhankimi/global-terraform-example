terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

# VPC
resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr       # Default in variables.tf : 10.0.0.0/16
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name        = "${var.project}-${var.region_alias}-vpc"
        Project     = var.project
        Environment = var.environment
        Region      = var.region_alias
    }
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id

    tags = {
        Name = "${var.project}-${var.region_alias}-igw"
        Project = var.project
    }
}

# Public Subnet
resource "aws_subnet" "public" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidr   # Default in variables.tf : 10.0.0.0/24
    availability_zone = var.availability_zone
    map_public_ip_on_launch = true

    tags = {
        Name = "${var.project}-${var.region_alias}-public-subnet"
        Project = var.project
    }
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }

    tags = {
      Name = "${var.project}-${var.region_alias}-public-rt"
    }
}

resource "aws_route_table_association" "public" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
  
}

# Security Group
resource "aws_security_group" "ec2" {
  name = "${var.project}-${var.region_alias}-ec2-sg"
  description = "Allow SSH and HTTP"
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project}-${var.region_alias}-ec2-sg"
    Project = var.project
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
    security_group_id = aws_security_group.ec2.id
    description = "Allow SSH"
    from_port = 22
    to_port = 22
    cidr_ipv4 = var.allowed_ssh_cidr
    ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "http" {
    security_group_id = aws_security_group.ec2.id
    description = "Allow HTTP"
    from_port = 80
    to_port = 80
    cidr_ipv4 = "0.0.0.0/0"
    ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.ec2.id
  description       = "Allow all outbound traffic"
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}


# EC2 Instance
# Get AMI ID (Amazon Linux in this case)
data "aws_ami" "amazon_linux" {
    most_recent = true
    owners = ["amazon"]

    filter {
      name = "name"
      values = ["al2023-ami-*-x86_64"]
    }

    filter {
      name = "virtualization-type"
      values = ["hvm"]
    }
}

# Attach role, to be able to get image from registry
resource "aws_iam_role" "ec2" {
  name = "${var.project}-${var.region_alias}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecr" {
  role       = aws_iam_role.ec2.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2" {
  name = "${var.project}-${var.region_alias}-ec2-profile"
  role = aws_iam_role.ec2.name
}

resource "aws_instance" "app" {
    ami = data.aws_ami.amazon_linux.id
    instance_type = var.instance_type # Default is t3.micro
    subnet_id = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.ec2.id]
    key_name = var.key_name

    iam_instance_profile = aws_iam_instance_profile.ec2.name    # ECR

    user_data = <<-EOF
      #!/bin/bash
      dnf update -y
      dnf install -y docker
      systemctl start docker
      systemctl enable docker
      aws ecr get-login-password --region ${var.region_full} | \
      docker login --username AWS --password-stdin ${var.ecr_repository_url}
      docker run -d -p 80:80 --name app --restart always ${var.ecr_repository_url}:latest
    EOF

    tags = {
        Name        = "${var.project}-${var.region_alias}-app"
        Project     = var.project
        Environment = var.environment
        Region      = var.region_alias
    }
}