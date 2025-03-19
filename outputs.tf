output "arn" {
  description = "ARN of the bucket"
  value       = aws_s3_bucket.s3_bucket.arn
}

output "name" {
  description = "Name (id) of the bucket"
  value       = aws_s3_bucket.s3_bucket.id
}

output "domain" {
  description = "Domain name of the bucket"
  value       = aws_s3_bucket_website_configuration.s3_bucket.website_domain
}

output "website_endpoint" {
  description = "Website endpoint URL"
  value       = aws_s3_bucket_website_configuration.s3_bucket.website_endpoint
}

# Outputs

output "access_key_id" {
  description = "The Access Key ID generated for the IAM user to use with the storage bucket."
  value       = aws_iam_access_key.bucket_access_key.id
}

output "secret_access_key" {
  description = "The Secret Access Key generated for the IAM user to use with the storage bucket."
  value       = aws_iam_access_key.bucket_access_key.secret
  sensitive   = true
}
