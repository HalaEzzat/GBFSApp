output "ec2_public_ip" {
  value       = aws_instance.docker_instance.public_ip
  description = "The public IP address of the EC2 instance."
}

variable "s3_bucket_name" {
  default = "my-terraform-state-bucket"
}