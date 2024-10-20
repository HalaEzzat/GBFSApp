# IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "gbfs-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy_attachment" "lambda_policy" {
  role      = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# IAM Role for Grafana
resource "aws_iam_role" "grafana_role" {
  name = "grafana-iam-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# IAM Policy for DynamoDB access
resource "aws_iam_policy" "grafana_dynamodb_policy" {
  name        = "grafana-dynamodb-policy"
  description = "Policy to allow Grafana to access DynamoDB"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "dynamodb:GetItem",
        "dynamodb:Scan",
        "dynamodb:Query"
      ],
      Resource = aws_dynamodb_table.vehicle_stats.arn  # Use the ARN of your DynamoDB table
    }]
  })
}

# Attach the policy to the Grafana role
resource "aws_iam_role_policy_attachment" "grafana_policy_attachment" {
  role       = aws_iam_role.grafana_role.name
  policy_arn = aws_iam_policy.grafana_dynamodb_policy.arn
}
