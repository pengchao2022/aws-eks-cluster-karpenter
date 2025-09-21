aws_region = "us-east-1"
vpc_id     = "vpc-0a4d0ce9036000d08"
public_subnet_ids = [
  "subnet-091d2076e9e9c1e3e",
  "subnet-085330a063b4d170e",
  "subnet-04ce9d65578c44de0",
] #this is for alb to use
private_subnet_id = "subnet-021cbefd6098d88a6"
key_pair_name     = "jenkins-key-pair"
instance_type     = "t3.micro"
ubuntu_version    = "20.04"
