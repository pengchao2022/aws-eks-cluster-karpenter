terraform {
  backend "s3" {
    bucket         = "terraformstatefile090909"
    key            = "aws-ec2-jenkins.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}                          