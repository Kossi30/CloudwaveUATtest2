
resource "aws_s3_bucket" "mezu" {
  bucket = "mezu-bucket"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "ssec" {
  bucket = aws_s3_bucket.mezu.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.ample.arn
    }
  }

}


resource "aws_s3_bucket_lifecycle_configuration" "lcr" {
  bucket = aws_s3_bucket.mezu.id
  rule {
    id     = "lcr-rule"
    status = "Enabled"

    transition {
      days          = 1
      storage_class = "INTELLIGENT_TIERING"
    }
  }
}
