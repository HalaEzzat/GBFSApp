variable "aws_region" {
  description = "The AWS region to deploy resources."
  default     = "us-east-1"
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table for vehicle stats."
  default     = "vehicle-stats"
}
