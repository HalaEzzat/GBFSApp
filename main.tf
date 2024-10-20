provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./vpc"
}

module "iam" {
  source = "./iam"
}

module "dynamodb" {
  source = "./dynamodb"
}

module "lambda" {
  source = "./lambda"
}

module "grafana" {
  source = "./grafana"
}
