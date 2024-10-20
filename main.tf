module "vpc" {
  source = "./vpc"
}

module "iam" {
  source = "./iam"
}

module "dynamodb" {
  source     = "./dynamodb"
  table_name = var.dynamodb_table_name
}

module "lambda" {
  source         = "./lambda"
  dynamodb_table = module.dynamodb.table_name
  lambda_role_arn = module.iam.lambda_role_arn
}

module "grafana" {
  source  = "./grafana"
  vpc_id  = module.vpc.id    # Correct reference here!
}

output "grafana_public_ip" {
  value = module.grafana.grafana_public_ip
}
