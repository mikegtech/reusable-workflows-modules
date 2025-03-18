variable "aws_region" {
  description = "AWS region for all resources."
}

variable "enable_s3_tables" {
  description = "Enable S3 table support with AWS Glue and Athena"
  type        = bool
  default     = false
}

variable "database_name" {
  description = "Name of the Glue/Athena database"
  type        = string
  default     = ""
}

variable "table_name" {
  description = "Name of the Glue/Athena table"
  type        = string
  default     = ""
}

variable "table_format" {
  description = "Format of the table data (e.g., 'parquet', 'csv')"
  type        = string
  default     = "parquet"
}

variable "table_data_path" {
  description = "S3 path where table data is stored"
  type        = string
  default     = "data/"
}

variable "table_columns" {
  description = "List of column definitions for the table"
  type = list(object({
    name = string
    type = string
  }))
  default = []
}

variable "athena_output_path" {
  description = "S3 path for Athena query results"
  type        = string
  default     = "athena-output/"
}

variable "s3_bucket_name" {
  type        = string
  description = "The name of the S3 bucket to store the Lambda function code"
  default     = ""
}

variable "s3_object_key" {
  type        = string
  description = "The S3 bucket object key, referring to the zip file"
  default     = ""
}

variable "lambda_jar_relative_path" {
  type        = string
  description = "The relative path of the Lambda jar file"
  default     = ""
}
