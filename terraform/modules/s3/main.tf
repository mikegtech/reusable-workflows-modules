terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.65.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  # default tags per https://registry.terraform.io/providers/hashicorp/aws/latest/docs#default_tags-configuration-block
  default_tags {
    tags = {
      env       = "dev"
      ManagedBy = "Terraform"
    }
  }
}

//using archive_file data source to zip the lambda code:
data "archive_file" "lambda_code" {
  type        = "zip"
  source_file = "${path.module}/${var.lambda_jar_relative_path}"
  output_path = "${path.module}/${var.s3_object_key}"
}

#######################################
# create S3 bucket to upload the zip
#######################################
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_ownership_controls" "static_site" {
  bucket = aws_s3_bucket.lambda_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_object" "lambda_code" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = var.s3_object_key
  source = data.archive_file.lambda_code.output_path
  etag   = filemd5(data.archive_file.lambda_code.output_path)
}

# AWS Glue Catalog Database
resource "aws_glue_catalog_database" "s3_table_db" {
  count = var.enable_s3_tables ? 1 : 0
  name  = var.database_name
}

# AWS Glue Catalog Table
resource "aws_glue_catalog_table" "s3_table" {
  count         = var.enable_s3_tables ? 1 : 0
  name          = var.table_name
  database_name = aws_glue_catalog_database.s3_table_db[0].name

  table_type = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL              = "TRUE"
    "classification"      = var.table_format
    "typeOfData"         = "file"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.lambda_bucket.bucket}/${var.table_data_path}"
    input_format  = var.table_format == "parquet" ? "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat" : "org.apache.hadoop.mapred.TextInputFormat"
    output_format = var.table_format == "parquet" ? "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat" : "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "table-serde"
      serialization_library = var.table_format == "parquet" ? "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe" : "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
    }

    dynamic "columns" {
      for_each = var.table_columns
      content {
        name = columns.value["name"]
        type = columns.value["type"]
      }
    }
  }
}

# Athena Workgroup
resource "aws_athena_workgroup" "s3_tables" {
  count = var.enable_s3_tables ? 1 : 0
  name  = "${var.database_name}-workgroup"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.lambda_bucket.bucket}/${var.athena_output_path}"
    }
  }
}
