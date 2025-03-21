provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name

  tags = var.tags
}

resource "aws_s3_bucket_website_configuration" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "s3_bucket" {
  depends_on = [
    aws_s3_bucket_public_access_block.s3_bucket,
    aws_s3_bucket_ownership_controls.s3_bucket,
  ]

  bucket = aws_s3_bucket.s3_bucket.id

  acl = "public-read"
}

resource "aws_s3_bucket_policy" "s3_bucket" {
  bucket = aws_s3_bucket.s3_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          aws_s3_bucket.s3_bucket.arn,
          "${aws_s3_bucket.s3_bucket.arn}/*",
        ]
      },
    ]
  })

  depends_on = [ aws_s3_bucket_public_access_block.s3_bucket ]
}

resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.s3_bucket.id
  key          = "index.html"
  source       = "www/index.html"
  content_type = "text/html"

  etag = filemd5("www/index.html")
}

resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.s3_bucket.id
  key          = "error.html"
  source       = "www/error.html"
  content_type = "text/html"

  etag = filemd5("www/error.html")
}

# Create an IAM user for the storage bucket access
resource "aws_iam_user" "bucket_user" {
  name = "bucket-user"
}

# Generate an access key for the IAM user
resource "aws_iam_access_key" "bucket_access_key" {
  user = aws_iam_user.bucket_user.name
}

resource "aws_iam_user_policy_attachment" "s3_policy_attachment" {
  user       = aws_iam_user.bucket_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

