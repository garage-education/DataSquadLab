output "s3_landing_zone_bucket_id" {
  description = "The name of the bucket."
  value       = module.landing_zone_bucket.s3_bucket_id
}

output "s3_landing_zone_bucket_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       = module.landing_zone_bucket.s3_bucket_arn
}
