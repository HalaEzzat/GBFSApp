resource "aws_security_group" "grafana_sg" {
  vpc_id = aws_vpc.gbfs_vpc.id

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Adjust as necessary for security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "grafana-security-group" }
}

# EC2 Instance for Grafana
resource "aws_instance" "grafana" {
  ami           = "ami-0c55b159cbfafe1f0"  # Use an appropriate Grafana AMI for your region
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
