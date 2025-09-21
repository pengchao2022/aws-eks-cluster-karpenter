aws_region = "us-east-1"
vpc_id     = "vpc-0a4d0ce9036000d08"
public_subnet_ids = [
  "subnet-091d2076e9e9c1e3e",
  "subnet-085330a063b4d170e",
  "subnet-04ce9d65578c44de0",
] #this is for alb to use
private_subnet_id = "subnet-021cbefd6098d88a6"
instance_type     = "t3.micro"
ubuntu_version    = "20.04"
key_pair_name     = "ssh-for-jenkins-server"
# this is the id_rsa.pub content of your bastion server
public_key_content = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC2+DSKIw4n9EO8svvfI1SsHvfDANXY61LDFp+sIdgoVxO40UHlkdTNSEj299BfUIxOzL8OE76ITDOWXkC4wn03gOyYqlIQdpDfeSRum5mrucl/Fbt3ak5kGEYbN/4UkMNR56qRWsyvOE5QblZSxjCtC5vMofp5u/IEx5js262w7R9mpFRdhKZA9uoM6co6ZGXCXvL/Xvd9Z5w4wRyn+sXRA54OzttWHzvBQkXr5+GcAgvMqi7s+pXRyXmgqsZDLpShh/SXfcODxbtaV2QUtEleF2RBBLyhVWncBL9lfroPxQ6/9IXOI+p/5iNaw+evKjTzj3p8gT9sLEmg9MSU3x9Iy3I+dsjwr7GrL+Of6Q/GH6fuG+cvk2Q6k837tdtIOsEskWYL2K77hfa7Po9qT+Ch5E6EmyaTQuoAWFZRa8I0SVYZREUarUSHSAGqfS7XOKZiAZ5TYW1n4ZobR5duVlRcEBBV+BhikRo5N2hz4wyp/jFF+Xsm2K1LMzGD8eC0u28= ubuntu@ip-172-20-1-47"
