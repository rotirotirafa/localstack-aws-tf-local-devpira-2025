output "bucket_de_pedidos_nome" {
  description = "O nome do bucket S3 criado"
  value       = aws_s3_bucket.bucket_de_pedidos.bucket
}

output "fila_de_pedidos_url" {
  description = "A URL da fila SQS principal"
  value       = aws_sqs_queue.fila_de_pedidos.id
}

output "tabela_dynamodb_nome" {
  description = "O nome da tabela DynamoDB"
  value       = aws_dynamodb_table.tabela_pedidos.name
}

output "nome_funcao_lambda" {
  description = "O nome da função Lambda"
  value       = aws_lambda_function.processador_de_pedidos.function_name
}