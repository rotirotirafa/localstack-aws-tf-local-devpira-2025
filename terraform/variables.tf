# --- Variáveis de Ambiente ---

variable "env" {
  description = "O nome do ambiente (ex: local, dev, prod)"
  type        = string
  default     = "local"
}

variable "aws_region" {
  description = "A região da AWS para criar os recursos"
  type        = string
  default     = "us-east-1"
}

# --- Variáveis dos Recursos ---

variable "s3_bucket_name" {
  description = "O nome base para o bucket S3"
  type        = string
}

variable "sqs_queue_name" {
  description = "O nome base para a fila SQS"
  type        = string
}

variable "sqs_dlq_name" {
  description = "O nome base para a fila DLQ"
  type        = string
}

variable "dynamo_table_name" {
  description = "O nome base para a tabela DynamoDB"
  type        = string
}

variable "lambda_function_name" {
  description = "O nome base para a função Lambda"
  type        = string
}

# --- Variáveis da Lambda ---

variable "lambda_source_dir" {
  description = "O caminho para o código-fonte da Lambda"
  type        = string
}

variable "lambda_handler" {
  description = "O 'entrypoint' (handler) da função Lambda"
  type        = string
}

variable "lambda_runtime" {
  description = "O runtime (linguagem) da função Lambda"
  type        = string
}