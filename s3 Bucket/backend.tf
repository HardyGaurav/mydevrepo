resource "aws_s3_bucket" "b1" {
  bucket = "testing-bucket02222"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
    apply_server_side_encryption_by_default {
       kms_master_key_id = aws_kms_key.terraform-bucket-key.arn
       sse_algorithm     = "aws:kms"
    }
  }
  }
}


resource "aws_s3_bucket_public_access_block" "block" {
 bucket = aws_s3_bucket.b1.id

 block_public_acls       = true
 block_public_policy     = true
 ignore_public_acls      = true
 restrict_public_buckets = true
}


resource "aws_dynamodb_table" "statelock" {
  name = "state-lock"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "LockID"
  attribute {
    name ="LockID"
    type= "S" 
  }
}


terraform {
  backend "s3" {
    bucket ="testing-bucket02222"
    dynamodb_table= "state-lock"
    key="statefile/terraform.tfstate"
    region="us-west-2"
    kms_key_id     = "alias/terraform-bucket-key"
    encrypt = true 
  }
}
