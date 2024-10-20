variable "aws_region" {
  description = "The AWS region to deploy to."
  default     = "us-east-1"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name."
  default     = "gbfs_vehicle_stats"
}
