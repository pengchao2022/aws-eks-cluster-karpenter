variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_id" {
  description = "Existing VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB (at least two)"
  type        = list(string)
}

variable "private_subnet_id" {
  description = "Private subnet ID for EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro" # 使用符合免费套餐的实例类型
}

variable "jenkins_port" {
  description = "Jenkins web interface port"
  type        = number
  default     = 8080
}

variable "agent_port" {
  description = "Jenkins agent port"
  type        = number
  default     = 50000
}

variable "docker_image" {
  description = "Jenkins Docker image"
  type        = string
  default     = "jenkins/jenkins:lts"
}

variable "private_ip" {
  description = "Private IP address for the EC2 instance (optional)"
  type        = string
  default     = null
}

variable "alb_port" {
  description = "ALB listener port"
  type        = number
  default     = 80
}

variable "alb_certificate_arn" {
  description = "ARN of SSL certificate for HTTPS listener (optional)"
  type        = string
  default     = null
}

variable "ubuntu_version" {
  description = "Ubuntu version to use"
  type        = string
  default     = "20.04"
}

variable "key_pair_name" {
  description = "Name for the SSH key pair"
  type        = string
  default     = "jenkins-key-pair"
}