# --- 1. Banco de Dados (DynamoDB) ---
resource "aws_dynamodb_table" "tabela_pedidos" {

  name           = "${var.dynamo_table_name}-${var.env}"
  billing_mode   = "PAY_PER_REQUEST" # modo sob demanda, existem outros modos como provisioned
  hash_key       = "pedidoId" # chave primária da tabela

  attribute { 
    # definição do atributo que é a chave primária
    name = "pedidoId"
    type = "S"
  }

  # Para outros atributos, índices secundários, etc, veja a documentação oficial:
  # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table
}

# --- 2. Fila (SQS) ---
resource "aws_sqs_queue" "fila_de_pedidos" {
  name = "${var.sqs_queue_name}-${var.env}"
  
  redrive_policy = jsonencode({
    # Configuração da Dead Letter Queue (DLQ)
    deadLetterTargetArn = aws_sqs_queue.fila_pedidos_falhados.arn # ARN da fila de falhados
    maxReceiveCount     = 3 # número máximo de tentativas antes de enviar para a DLQ
  })
}

resource "aws_sqs_queue" "fila_pedidos_falhados" {
  # Dead Letter Queue (DLQ)
  name = "${var.sqs_dlq_name}-${var.env}"
}

# --- 3. Bucket de Armazenamento (S3) ---
resource "aws_s3_bucket" "bucket_de_pedidos" {
  bucket = "${var.s3_bucket_name}-${var.env}"
  # Não subir esta linha em Produção sem pensar bem! Aqui é só para facilitar os testes locais.
  force_destroy = true
}

resource "aws_s3_bucket_notification" "notificacao_sqs" {
  # Configuração para notificar a fila SQS quando novos objetos forem criados no bucket
  bucket = aws_s3_bucket.bucket_de_pedidos.id

  queue {
    queue_arn     = aws_sqs_queue.fila_de_pedidos.arn
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".json"
  }

  depends_on = [aws_sqs_queue_policy.permitir_s3]
}

resource "aws_sqs_queue_policy" "permitir_s3" {
  queue_url = aws_sqs_queue.fila_de_pedidos.id

  policy = jsonencode({
    # Permitir que o S3 envie mensagens para a fila SQS
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

data "archive_file" "zip_lambda" {
  # Cria um arquivo ZIP com o código da função Lambda
  type        = "zip" # formato do arquivo
  output_path = "processar_pedido.zip" # nome do arquivo ZIP gerado

  source {
    # arquivo principal da função Lambda
    content  = file("${var.lambda_source_dir}/main.py")
    filename = "main.py" # nome dentro do ZIP
  }

  dynamic "source" {
    # adicionar requirements.txt
    for_each = fileexists("${var.lambda_source_dir}/requirements.txt") ? [1] : []
    content {
      content  = file("${var.lambda_source_dir}/requirements.txt")
      filename = "requirements.txt"
    }
  }
}

resource "aws_lambda_function" "processador_de_pedidos" {
  # Definição da função Lambda
  function_name = "${var.lambda_function_name}-${var.env}"
  role          = aws_iam_role.role_lambda.arn # papel IAM associado à função
  handler       = var.lambda_handler # ponto de entrada da função
  runtime       = var.lambda_runtime # runtime da função (ex: python3.10)
  
  filename         = data.archive_file.zip_lambda.output_path # arquivo ZIP com o código
  source_code_hash = data.archive_file.zip_lambda.output_base64sha256 # hash do código para versionamento

  environment {
    # Variáveis de ambiente para a função Lambda
    variables = {
      DYNAMO_TABLE_NAME = aws_dynamodb_table.tabela_pedidos.name
    }
  }
}

resource "aws_lambda_event_source_mapping" "gatilho_sqs" {
  event_source_arn = aws_sqs_queue.fila_de_pedidos.arn
  function_name    = aws_lambda_function.processador_de_pedidos.arn
  batch_size       = 1
}

# --- 5. Permissões (IAM) ---
resource "aws_iam_role" "role_lambda" {
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
  name   = "policy-lambda-processador-${var.env}"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = aws_sqs_queue.fila_de_pedidos.arn
      },
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
  role       = aws_iam_role.role_lambda.name
  policy_arn = aws_iam_policy.politica_lambda.arn
}