
# Create new S3bucket
resource "aws_s3_bucket" "bucket" {
  bucket             = var.bucket
  force_destroy      = false

  tags = {
    Name             = "My bucket"
    Environment      = "testing"
  }
}

###################################################################################################
###################################################################################################

# Enable s3 bucket versioning
resource "aws_s3_bucket_versioning" "s3-versioning" {
  bucket             = aws_s3_bucket.bucket.id
  versioning_configuration {
    status           = "Enabled"
  }
}


####################################################################################################
####################################################################################################

# Encrypt bucket using sse-algorithm
resource "aws_s3_bucket_server_side_encryption_configuration" "bucket-items" {
  bucket              = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm   = "AES256"
    }
  }
}