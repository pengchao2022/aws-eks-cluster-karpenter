aws_region = "us-east-1"
vpc_id     = "vpc-0a346dceeb8b922a6"
public_subnet_ids = [
  "subnet-0102416d2c47883c4",
  "subnet-0e3c240984542b792",
  "subnet-09f49cec00c38bdc1",
] #this is for alb to use
private_subnet_id = "subnet-0c33850d4d6866396"
instance_type     = "t3.micro"
ubuntu_version    = "20.04"
key_pair_name     = "ssh-for-jenkins-server"
# this is the id_rsa.pub content of your bastion server
public_key_content = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC2+DSKIw4n9EO8svvfI1SsHvfDANXY61LDFp+sIdgoVxO40UHlkdTNSEj299BfUIxOzL8OE76ITDOWXkC4wn03gOyYqlIQdpDfeSRum5mrucl/Fbt3ak5kGEYbN/4UkMNR56qRWsyvOE5QblZSxjCtC5vMofp5u/IEx5js262w7R9mpFRdhKZA9uoM6co6ZGXCXvL/Xvd9Z5w4wRyn+sXRA54OzttWHzvBQkXr5+GcAgvMqi7s+pXRyXmgqsZDLpShh/SXfcODxbtaV2QUtEleF2RBBLyhVWncBL9lfroPxQ6/9IXOI+p/5iNaw+evKjTzj3p8gT9sLEmg9MSU3x9Iy3I+dsjwr7GrL+Of6Q/GH6fuG+cvk2Q6k837tdtIOsEskWYL2K77hfa7Po9qT+Ch5E6EmyaTQuoAWFZRa8I0SVYZREUarUSHSAGqfS7XOKZiAZ5TYW1n4ZobR5duVlRcEBBV+BhikRo5N2hz4wyp/jFF+Xsm2K1LMzGD8eC0u28= ubuntu@ip-172-20-1-47"
