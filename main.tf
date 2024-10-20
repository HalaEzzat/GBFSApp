provider "aws" {
  region = var.aws_region
}

# VPC Configuration
resource "aws_vpc" "gbfs_vpc" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "gbfs-vpc" }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.gbfs_vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
  tags              = { Name = "public-subnet" }
}

resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.gbfs_vpc.id
  tags   = { Name = "internet-gateway" }
}

resource "aws_route_table" "public_route" {
  vpc_id = aws_vpc.gbfs_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route.id
}

# IAM Role for Grafana
resource "aws_iam_role" "grafana_role" {
  name = "grafana-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "grafana_ec2_policy" {
  role       = aws_iam_role.grafana_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_instance_profile" "grafana_instance_profile" {
  name = "grafana-instance-profile"
  role = aws_iam_role.grafana_role.name
}

# DynamoDB Table
resource "aws_dynamodb_table" "vehicle_stats" {
  name         = "vehicle-stats"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "provider"
  range_key    = "timestamp"

  attribute {
    name = "provider"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "N"
  }

  tags = { Name = "vehicle-stats-table" }
}

# Lambda Function to Fetch Data
resource "aws_lambda_function" "fetch_stats" {
  function_name = "fetch-stats"
  runtime       = "nodejs14.x"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  filename      = "lambda.zip"

  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.vehicle_stats.name
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# Grafana EC2 Instance
resource "aws_security_group" "grafana_sg" {
  vpc_id = aws_vpc.gbfs_vpc.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "grafana-security-group" }
}

resource "aws_instance" "grafana" {
  ami           = "ami-005fc0f236362e99f"  # Use an appropriate Grafana AMI for your region
  instance_type = "t2.micro"               # Ensure it's Free Tier eligible
  subnet_id     = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.grafana_sg.name]

  # Associate the IAM role with the EC2 instance
  iam_instance_profile = aws_iam_instance_profile.grafana_instance_profile.name

  # Install Grafana and configure the dashboard using a user data script
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y grafana
              systemctl enable grafana-server
              systemctl start grafana-server

              # Wait for Grafana to start
              sleep 10

              # Configure the DynamoDB datasource
              cat <<EOT > /etc/grafana/provisioning/datasources/dynamodb.yaml
              apiVersion: 1
              datasources:
                - name: DynamoDB
                  type: grafana-dynamodb-datasource
                  access: proxy
                  jsonData:
                    region: ${var.aws_region}
              EOT

              # Import the dashboard
              curl -X POST -H "Content-Type: application/json" \
              -d '{
                "dashboard": {
                  "id": null,
                  "title": "Bike Sharing Stats",
                  "panels": [
                    {
                      "type": "graph",
                      "title": "Available Bikes",
                      "targets": [
                        {
                          "refId": "A",
                          "target": "DynamoDB"
                        }
                      ],
                      "datasource": "DynamoDB"
                    }
                  ]
                },
                "overwrite": true
              }' http://admin:admin@localhost:3000/api/dashboards/db  # Use default credentials for demo purposes
              EOF

  tags = { Name = "Grafana Instance" }
}


# Output the Public IP of Grafana Instance
output "grafana_public_ip" {
  value = aws_instance.grafana.public_ip
}

