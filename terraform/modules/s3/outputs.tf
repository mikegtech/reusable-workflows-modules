output "s3_bucket_id" {
  description = "The ID of the S3 bucket"
  value       = aws_s3_bucket.lambda_bucket.id
}

output "glue_database_name" {
  description = "Name of the created Glue database"
  value       = var.enable_s3_tables ? aws_glue_catalog_database.s3_table_db[0].name : ""
}

output "glue_table_name" {
  description = "Name of the created Glue table"
  value       = var.enable_s3_tables ? aws_glue_catalog_table.s3_table[0].name : ""
}

output "athena_workgroup_name" {
  description = "Name of the created Athena workgroup"
  value       = var.enable_s3_tables ? aws_athena_workgroup.s3_tables[0].name : ""
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.lambda_bucket.arn
}
