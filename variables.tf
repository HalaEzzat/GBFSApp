variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}


variable "ssh_key_name" {
  description = "The name of the SSH key"
  default     = "id_rsa"
}

variable "ssh_private_key" {
  description = "private key"
}

