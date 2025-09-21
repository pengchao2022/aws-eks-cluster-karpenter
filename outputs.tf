output "jenkins_private_ip" {
  description = "Private IP address of the Jenkins server"
  value       = aws_instance.jenkins_server.private_ip
}

output "jenkins_alb_url" {
  description = "Jenkins ALB URL"
  value       = "http://${aws_lb.jenkins.dns_name}"
}

output "jenkins_alb_dns_name" {
  description = "Jenkins ALB DNS name"
  value       = aws_lb.jenkins.dns_name
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.jenkins_server.id
}

output "target_group_arn" {
  description = "Target group ARN"
  value       = aws_lb_target_group.jenkins.arn
}

output "alb_security_group_id" {
  description = "ALB security group ID"
  value       = aws_security_group.alb_sg.id
}

output "instance_security_group_id" {
  description = "Instance security group ID"
  value       = aws_security_group.jenkins_sg.id
}

output "ssh_connection_command" {
  description = "SSH connection command"
  value       = "ssh ubuntu@${aws_instance.jenkins_server.private_ip}"
}

