#!/bin/bash
set -e

# Configura variáveis de ambiente AWS para Localstack, pois o AWS CLI precisa delas
# mesmo que os valores sejam fictícios, a ferramenta exige sua presença.
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

echo "🏁 Iniciando o teste do fluxo do MVP..."

# Configuração (nomes definidos no local.tfvars)
BUCKET_NAME="bucket-pedidos-devpira-local"
TABLE_NAME="pedidos-processados-local"
PEDIDO_ID="pedido-$(date +%s)"
FILE_NAME="${PEDIDO_ID}.json"
ENDPOINT="--endpoint-url=http://localhost:4566"

# 1. Cria o arquivo
echo '{ "produto": "Camiseta DEVPIRA", "valor": 59.90 }' > /tmp/${FILE_NAME}

# 2. Upload S3
echo "📤 Enviando ${FILE_NAME} para o S3..."
aws s3 cp /tmp/${FILE_NAME} s3://${BUCKET_NAME}/ ${ENDPOINT}

# 3. Espera processamento
echo "⏳ Aguardando processamento (S3 -> SQS -> Lambda -> Dynamo)..."
sleep 5

# 4. Verifica DynamoDB
echo "🔎 Consultando DynamoDB..."
RESULT=$(aws dynamodb scan --table-name ${TABLE_NAME} ${ENDPOINT} --filter-expression "pedidoId = :id" --expression-attribute-values "{ \":id\": {\"S\": \"${PEDIDO_ID}\"} }")

echo $RESULT | jq