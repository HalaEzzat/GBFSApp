resource "aws_lambda_function" "fetch_stats" {
  filename         = "lambda.zip"  # Ensure this is built correctly
  function_name    = "gbfs-fetch-stats"
  role             = aws_iam_role.lambda_role.arn
  handler          = "handler.fetchStats"
  runtime          = "nodejs18.x"
  timeout          = 30
  security_group_ids = [aws_security_group.lambda_sg.id]
  subnet_ids       = [aws_subnet.private_subnet.id]

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.vehicle_stats.name
    }
  }
}

# CloudWatch Event to Schedule Lambda (Every 15 minutes)
resource "aws_cloudwatch_event_rule" "schedule" {
  name                 = "gbfs-schedule"
  schedule_expression  = "rate(15 minutes)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.schedule.name
  target_id = "gbfs-lambda"
  arn       = aws_lambda_function.fetch_stats.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fetch_stats.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule.arn
}
