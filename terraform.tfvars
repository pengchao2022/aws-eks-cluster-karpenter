aws_region = "us-east-1"
vpc_id     = "vpc-0f0ba675bc1f552d0"
public_subnet_ids = [
  "subnet-0d3da540c4e999ec0",
  "subnet-0e1f01fdc90e576ef",
  "subnet-06f4a75105215acd0",
] # alb 来使用
private_subnet_id = "subnet-0cebdc86baa14f187"
key_pair_name     = "jenkins-key-pair"
instance_type     = "t3.micro"
ubuntu_version    = "20.04"
