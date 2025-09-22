terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# obtain current VPC info
data "aws_vpc" "selected" {
  id = var.vpc_id
}

# use id_rsa.pub to login the server
resource "aws_key_pair" "jenkins" {
  key_name   = var.key_pair_name
  public_key = var.public_key_content
}


# create sg for alb
resource "aws_security_group" "alb_sg" {
  name        = "jenkins-alb-security-group"
  description = "Security group for Jenkins ALB"
  vpc_id      = data.aws_vpc.selected.id

  # allow http
  ingress {
    from_port   = var.alb_port
    to_port     = var.alb_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # allow http to access instance
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-alb-security-group"
  }
}

# create sg for instance
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-instance-security-group"
  description = "Security group for Jenkins server"
  vpc_id      = data.aws_vpc.selected.id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  # allow alb sg to access jenkins
  ingress {
    from_port       = var.jenkins_port
    to_port         = var.jenkins_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Jenkins proxy allow internal
  ingress {
    from_port   = var.agent_port
    to_port     = var.agent_port
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-instance-security-group"
  }
}

# create iam role for jenkins 
resource "aws_iam_role" "jenkins_role" {
  name = "jenkins-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_read_only" {
  role       = aws_iam_role.jenkins_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "jenkins_profile" {
  name = "jenkins-instance-profile"
  role = aws_iam_role.jenkins_role.name
}

# create EC2 instance
resource "aws_instance" "jenkins_server" {
  ami                         = "ami-0c7217cdde317cfec" # Ubuntu 20.04 LTS in us-east-1
  instance_type               = var.instance_type
  subnet_id                   = var.private_subnet_id         # private subnet 
  key_name                    = aws_key_pair.jenkins.key_name # ssh key 
  iam_instance_profile        = aws_iam_instance_profile.jenkins_profile.name
  associate_public_ip_address = false          # no public ip assigned
  private_ip                  = var.private_ip # assign private ip address

  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  user_data = filebase64("${path.module}/user_data.sh")

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "jenkins-server"
  }
}

# create target group for jenkins instance 
resource "aws_lb_target_group" "jenkins" {
  name     = "jenkins-target-group"
  port     = var.jenkins_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.selected.id

  health_check {
    path                = "/login"
    port                = var.jenkins_port
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 30
    matcher             = "200-399"
  }

  tags = {
    Name = "jenkins-target-group"
  }
}

# create attachment for target group
resource "aws_lb_target_group_attachment" "jenkins" {
  target_group_arn = aws_lb_target_group.jenkins.arn
  target_id        = aws_instance.jenkins_server.id
  port             = var.jenkins_port
}

# create alb using public subnet
resource "aws_lb" "jenkins" {
  name               = "jenkins-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false

  tags = {
    Name = "jenkins-alb"
  }
}

# create listener for alb
resource "aws_lb_listener" "jenkins" {
  load_balancer_arn = aws_lb.jenkins.arn
  port              = var.alb_port
  protocol          = var.alb_certificate_arn != null ? "HTTPS" : "HTTP"
  certificate_arn   = var.alb_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenkins.arn
  }
}

# create listener for http, will be redirect to https
resource "aws_lb_listener" "jenkins_http_redirect" {
  count = var.alb_certificate_arn != null ? 1 : 0

  load_balancer_arn = aws_lb.jenkins.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}