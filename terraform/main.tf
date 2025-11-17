# --- 1. Banco de Dados (DynamoDB) ---
resource "aws_dynamodb_table" "tabela_pedidos" {
  provider = var.env == "local" ? aws.localstack : aws

  name           = "${var.dynamo_table_name}-${var.env}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "pedidoId"

  attribute {
    name = "pedidoId"
    type = "S"
  }
}

# --- 2. Fila (SQS) ---
resource "aws_sqs_queue" "fila_de_pedidos" {
  provider = var.env == "local" ? aws.localstack : aws

  name = "${var.sqs_queue_name}-${var.env}"
  
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.fila_pedidos_falhados.arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue" "fila_pedidos_falhados" {
  provider = var.env == "local" ? aws.localstack : aws
  name = "${var.sqs_dlq_name}-${var.env}"
}

# --- 3. Bucket de Armazenamento (S3) ---
resource "aws_s3_bucket" "bucket_de_pedidos" {
  provider = var.env == "local" ? aws.localstack : aws

  bucket = "${var.s3_bucket_name}-${var.env}"
}

resource "aws_s3_bucket_notification" "notificacao_sqs" {
  provider = var.env == "local" ? aws.localstack : aws 

  bucket = aws_s3_bucket.bucket_de_pedidos.id

  queue {
    queue_arn     = aws_sqs_queue.fila_de_pedidos.arn
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".json"
  }

  depends_on = [aws_sqs_queue_policy.permitir_s3]
}

resource "aws_sqs_queue_policy" "permitir_s3" {
  provider = var.env == "local" ? aws.localstack : aws 

  queue_url = aws_sqs_queue.fila_de_pedidos.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = "*",
        Action    = "sqs:SendMessage",
        Resource  = aws_sqs_queue.fila_de_pedidos.arn,
        Condition = {
          ArnEquals = { "aws:SourceArn" = aws_s3_bucket.bucket_de_pedidos.arn }
        }
      }
    ]
  })
}

# --- 4. Função de Processamento (Lambda) ---

# O 'archive_file' não é um recurso 'aws_', ele é local.
# Por isso, ele NÃO precisa do meta-argumento 'provider'.
# --- 4. Função de Processamento (Lambda) ---

# Primeiro, precisamos compactar o código-fonte da nossa Lambda.
data "archive_file" "zip_lambda" {
  type        = "zip"
  output_path = "processar_pedido.zip"

  # Aponta para o arquivo Python principal
  source {
    content  = file("${var.lambda_source_dir}/main.py")
    filename = "main.py"
  }

  # Se houver um requirements.txt, ele também será incluído
  # O 'fileexists' garante que o Terraform não quebre se o arquivo não existir.
  dynamic "source" {
    for_each = fileexists("${var.lambda_source_dir}/requirements.txt") ? [1] : []
    content {
      content  = file("${var.lambda_source_dir}/requirements.txt")
      filename = "requirements.txt"
    }
  }
}

# --- 5. Permissões (IAM) ---
resource "aws_iam_role" "role_lambda" {
  provider = var.env == "local" ? aws.localstack : aws 

  name = "role-lambda-processador-${var.env}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "politica_lambda" {
  provider = var.env == "local" ? aws.localstack : aws

  name   = "policy-lambda-processador-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # Permissão SQS
      {
        Effect   = "Allow",
        Action   = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = aws_sqs_queue.fila_de_pedidos.arn
      },
      # Permissão DynamoDB
      {
        Effect   = "Allow",
        Action   = [
          "dynamodb:PutItem"
        ],
        Resource = aws_dynamodb_table.tabela_pedidos.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "anexo_politica" {
  provider = var.env == "local" ? aws.localstack : aws 

  role       = aws_iam_role.role_lambda.name
  policy_arn = aws_iam_policy.politica_lambda.arn
}