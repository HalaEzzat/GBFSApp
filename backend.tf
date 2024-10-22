terraform {
  backend "s3" {
    bucket         = "hala-elhamahmy"
    key            = "global/terraform.tfstate"
    region         = "us-east-1"
  }
}
