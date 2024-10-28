terraform {
  backend "local" {}  
}

provider "aws" {
  region = "us-east-1"  
}

resource "aws_s3_bucket" "state_bucket" {
  bucket = "terraform-state-bucket-carcy"  
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name = "Terraform State Bucket"
    Environment = "Dev"
  }
}

resource "aws_dynamodb_table" "state_bucket_lock" {
  name           = "terraform-state-lock"  
  read_capacity  = 5 
  write_capacity = 5  
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name = "Terraform State Lock Table"
    Environment = "Dev"
  }
}
