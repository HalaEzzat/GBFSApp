variable "aws_region" {
  description = "The AWS region to deploy resources in"
  default     = "us-east-1"
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for vehicle stats"
  default     = "vehicle_stats"
}
