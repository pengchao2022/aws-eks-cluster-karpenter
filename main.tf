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

# 获取现有 VPC 信息
data "aws_vpc" "selected" {
  id = var.vpc_id
}

# 创建 TLS 私钥
resource "tls_private_key" "jenkins_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 将私钥保存到本地文件
resource "local_file" "private_key" {
  content         = tls_private_key.jenkins_key.private_key_pem
  filename        = "${var.key_pair_name}.pem"
  file_permission = "0600"
}

# 创建 AWS 密钥对
resource "aws_key_pair" "jenkins" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.jenkins_key.public_key_openssh
}

# 创建 ALB 安全组
resource "aws_security_group" "alb_sg" {
  name        = "jenkins-alb-security-group"
  description = "Security group for Jenkins ALB"
  vpc_id      = data.aws_vpc.selected.id

  # HTTP 访问
  ingress {
    from_port   = var.alb_port
    to_port     = var.alb_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # 出站规则 - 允许 ALB 访问实例
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

# 创建实例安全组
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins-instance-security-group"
  description = "Security group for Jenkins server"
  vpc_id      = data.aws_vpc.selected.id

  # SSH 访问 (仅允许VPC内部访问)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  # 允许 ALB 安全组访问 Jenkins
  ingress {
    from_port       = var.jenkins_port
    to_port         = var.jenkins_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Jenkins 代理端口 (仅允许VPC内部访问)
  ingress {
    from_port   = var.agent_port
    to_port     = var.agent_port
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected.cidr_block]
  }

  # 出站规则
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

# 创建 IAM 角色和策略
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

# 创建 EC2 实例 (无公网IP) - 使用私有子网
resource "aws_instance" "jenkins_server" {
  ami                         = "ami-0c7217cdde317cfec" # Ubuntu 20.04 LTS in us-east-1
  instance_type               = var.instance_type
  subnet_id                   = var.private_subnet_id         # 使用私有子网
  key_name                    = aws_key_pair.jenkins.key_name # 使用新创建的密钥对
  iam_instance_profile        = aws_iam_instance_profile.jenkins_profile.name
  associate_public_ip_address = false          # 确保不分配公网IP
  private_ip                  = var.private_ip # 可选指定私有IP

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

# 创建目标组
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

# 创建目标组附件
resource "aws_lb_target_group_attachment" "jenkins" {
  target_group_arn = aws_lb_target_group.jenkins.arn
  target_id        = aws_instance.jenkins_server.id
  port             = var.jenkins_port
}

# 创建 ALB - 使用公有子网
resource "aws_lb" "jenkins" {
  name               = "jenkins-alb"
  internal           = false # 面向互联网的 ALB
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids # 使用公有子网

  enable_deletion_protection = false

  tags = {
    Name = "jenkins-alb"
  }
}

# 创建 ALB 监听器
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

# 如果没有提供证书，创建 HTTP 监听器
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