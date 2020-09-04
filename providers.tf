// AWS provider

provider "aws" {
  region = var.aws_region
  shared_credentials_file = "$HOME/.aws/credentials"
}
