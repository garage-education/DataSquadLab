output "s3_landing_zone_bucket_id" {
  description = "The name of the bucket."
  value       = module.landing_zone_bucket.s3_bucket_id
}

output "s3_landing_zone_bucket_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       = module.landing_zone_bucket.s3_bucket_arn
}

output "s3_archived_zone_bucket_id" {
  description = "The name of the bucket."
  value       = module.archived_zone_bucket.s3_bucket_id
}

output "s3_archived_zone_bucket_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       = module.archived_zone_bucket.s3_bucket_arn
}


output "s3_airflow_log_bucket_id" {
  description = "The name of the bucket."
  value       = module.airflow_log_bucket.s3_bucket_id
}

output "s3_airflow_log_bucket_arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       = module.airflow_log_bucket.s3_bucket_arn
}
