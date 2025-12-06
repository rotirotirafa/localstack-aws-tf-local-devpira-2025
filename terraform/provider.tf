terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Provider Único
# Quando rodar 'tflocal', ele injeta os endpoints do Localstack automaticamente.
# Quando rodar 'terraform', ele usa a AWS Real.
provider "aws" {
  region = var.aws_region
  s3_use_path_style = true
  
  # Não colocamos access_key aqui para não quebrar em Produção.
  # O tflocal lida com credenciais fake automaticamente.
  # Na AWS Real, ele vai pegar do seu ~/.aws/credentials
}