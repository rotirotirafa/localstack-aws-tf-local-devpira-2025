terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 1. PROVIDER PADRÃO (Nuvem AWS Real)
# Este será usado por padrão (para env 'dev', 'prod', etc.)
# Ele não precisa de nada, pois usará as credenciais do ambiente.
provider "aws" {
  region = var.aws_region
}

# 2. PROVIDER "APELIDADO" (Localstack)
# Este só será usado quando o chamarmos explicitamente com 'provider = aws.localstack'
provider "aws" {
  alias = "localstack"

  region     = var.aws_region
  access_key = "test"
  secret_key = "test"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    s3       = "http://localhost:4566"
    sqs      = "http://localhost:4566"
    lambda   = "http://localhost:4566"
    dynamodb = "http://localhost:4566"
    iam      = "http://localhost:4566"
  }
}