provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = "hala-elhamahmy"

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {
  bucket = "hala-elhamahmy"

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"  # AWS-managed key
    }
  }
}

resource "aws_s3_bucket_public_access_block" "secure" {
  bucket = "hala-elhamahmy"

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
