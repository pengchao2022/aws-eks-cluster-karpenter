terraform {
  backend "s3" {
    bucket         = "terraformstatefile090909"
    key            = "spring_aws_terraform_kar.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}                          