provider "aws" {
  region     = var.deployment_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token      = var.session_token
}

# Fetch the latest Ubuntu 22.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]  # Canonical's AWS account ID
}

# Fetch the default VPC
data "aws_vpc" "default_vpc" {
  default = true
}

# Fetch default subnets associated with the VPC
data "aws_subnets" "default_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
}

# Security group for application instances
resource "aws_security_group" "app_security" {
  name        = "app_security_group"
  description = "Security group for application instances"
  vpc_id      = data.aws_vpc.default_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["1.43.238.123/32"]  
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AppSecurityGroup"
  }
}

# Security group for the database instance
resource "aws_security_group" "db_security" {
  name        = "db_security_group"
  description = "Security group for database instance"
  vpc_id      = data.aws_vpc.default_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["1.43.238.123/32"]  
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Allow internal access for the database
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DBSecurityGroup"
  }
}

resource "aws_instance" "app_instance" {
  count         = 2
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ec2_type
  key_name      = "ec2key"  # Use the new key pair name
  vpc_security_group_ids = [aws_security_group.app_security.id]
  subnet_id     = element(data.aws_subnets.default_subnets.ids, count.index)

  tags = {
    Name = "AppInstance-${count.index}"
  }
}

resource "aws_instance" "db_instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ec2_type
  key_name      = "ec2key"  # Use the new key pair name
  vpc_security_group_ids = [aws_security_group.db_security.id]
  subnet_id     = element(data.aws_subnets.default_subnets.ids, 0)

  tags = {
    Name = "DBInstance"
  }
}

# Elastic Load Balancer for app servers
resource "aws_elb" "app_load_balancer" {
  name               = "app-load-balancer"
  availability_zones = ["us-east-1a", "us-east-1b"]

  listener {
    instance_port     = 80
    instance_protocol = "HTTP"
    lb_port           = 80
    lb_protocol       = "HTTP"
  }

  instances = aws_instance.app_instance[*].id

  health_check {
    target              = "HTTP:80/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "AppLoadBalancer"
  }
}

# Outputs
output "app_instance_dns" {
  value = aws_instance.app_instance[*].public_dns
}

output "db_instance_dns" {
  value = aws_instance.db_instance.public_dns
}

output "load_balancer_dns" {
  value = aws_elb.app_load_balancer.dns_name
}

terraform {
  backend "s3" {
    bucket         = "terraform-state-bucket-carcy"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}


