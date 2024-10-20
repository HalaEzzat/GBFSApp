resource "aws_dynamodb_table" "vehicle_stats" {
  name           = var.dynamodb_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "provider"
  range_key      = "timestamp"

  attribute {
    name = "provider"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }
}
