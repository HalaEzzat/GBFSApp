provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./vpc/vpc.tf"
}

module "iam" {
  source = "./iam/iam.tf"
}

module "dynamodb" {
  source = "./dynamodb/dynamodb.tf"
}

module "lambda" {
  source = "./lambda/lambda.tf"
}

module "grafana" {
  source = "./grafana/grafana.tf"
}
