# DEVPIRA - Serverless Local Demo (Localstack + Terraform)

✅ TL;DR

Um projeto demo para executar uma arquitetura serverless AWS 100% local usando Localstack + Terraform. Ideal para demonstrar o fluxo S3 -> SQS -> Lambda -> DynamoDB com `tflocal` para aplicar a infraestrutura local.

---

## 🧩 Arquitetura & Fluxo
- Upload de um arquivo JSON no S3 -> Notificação S3 -> Mensagem enviada à SQS -> Lambda acionada pela SQS -> Processamento -> Gravação em DynamoDB.
- Serviços em uso (Localstack): `s3`, `sqs`, `lambda`, `dynamodb`, `iam`.

---

## ⚙️ Requisitos
- Docker & Docker Compose
- Terraform (opcional localmente; o demo usa `tflocal` para Localstack)
- Localstack CLI (para `tflocal`): pip install localstack
- AWS CLI (v2) — para executar comandos `aws` apontando para Localstack
- jq (opcional): para formatar saída JSON

> Note: Os scripts já exportam credenciais dummy (`test`/`test`) necessárias para o AWS CLI quando conectando ao Localstack.

---

## 🚀 Quick Start (em 3 comandos)
1. Subir os containers (Localstack + GUI dynamodb-admin)

```bash
docker compose up -d
```

2. Inicializar e aplicar a infraestrutura via Terraform (wrapper `tflocal` já usado no `Makefile`):

```bash
# Usando Makefile (recomendado)
make init

# ou diretamente
# tflocal init
# tflocal apply -var-file="environments/local.tfvars" -auto-approve
```

3. Executar o teste de ponta a ponta:

```bash
make test
# ou ./scripts/test_flow.sh
```

---

## 🔎 Testando o fluxo manualmente
Se preferir executar passos manualmente, os comandos principais são:

```bash
# Ajuste suas credenciais locais (dummy)
export AWS_ACCESS_KEY_ID=test
export AWS_SECRET_ACCESS_KEY=test
export AWS_DEFAULT_REGION=us-east-1

# Upload para o bucket local (definido como bucket-pedidos-devpira-local)
aws s3 cp /tmp/pedido-123.json s3://bucket-pedidos-devpira-local/ --endpoint-url=http://localhost:4566

# Esperar processamento e checar DynamoDB
aws dynamodb scan --table-name pedidos-processados-local --endpoint-url=http://localhost:4566 | jq
```

---

## 🧪 Scripts úteis (localizados em `scripts/`)
- `init_demo.sh` — Sobe o Localstack e aplica o Terraform (`tflocal`).
- `test_flow.sh` — Executa fluxo de teste: gera um arquivo JSON e faz upload para S3, aguarda processamento e consulta DynamoDB.
- `cleanup.sh` — Destroi recursos com `tflocal destroy` e derruba containers (`docker compose down -v`).

Você também pode usar os alvos do `Makefile`:
- `make init` — executa `init_demo.sh`
- `make test` — executa `test_flow.sh`
- `make clean` — executa `cleanup.sh`

---

## 🧭 Ports & Tools
- Localstack gateway: `http://localhost:4566`
- DynamoDB Admin GUI: `http://localhost:8001`

### Comandos AWS com Localstack
- Listar buckets: `aws --endpoint-url=http://localhost:4566 s3 ls`
- Listar filas: `aws --endpoint-url=http://localhost:4566 sqs list-queues`
- Listar Lambdas: `aws --endpoint-url=http://localhost:4566 lambda list-functions`
- Listar tabelas DynamoDB: `aws --endpoint-url=http://localhost:4566 dynamodb list-tables`

---

## 🗂 Recursos (nomes usados no ambiente local)
- S3 Bucket: `bucket-pedidos-devpira-local`
- SQS Queue: `fila-pedidos-devpira-local` (DLQ: `fila-pedidos-falhados-devpira-local`)
- DynamoDB Table: `pedidos-processados-local`
- Lambda: `processador-de-pedidos-local`

---

## 📝 Notas & Dicas
- `tflocal` é o wrapper do Localstack para rodar o `terraform` apontando para o Localstack. Se não estiver instalado, use `pip install localstack`.
- Se o `tflocal` não estiver disponível, você pode ajustar `provider.tf` e executar `terraform init`/`terraform apply` usando endpoints e credenciais locais manualmente.
- O script `test_flow.sh` aponta o AWS CLI para `http://localhost:4566` e usa credenciais fictícias (`test`).
- Para debug de Lambda, confira logs do container Localstack ou remova `LAMBDA_EXECUTOR=docker` para usar o executor local (mas para Lambdas que dependem de container this might change behavior).

---

## 🧾 License
MIT — veja `LICENSE`.

---

## 🔗 Recursos e referência rápida
- `docker-compose.yml` — configura serviços Localstack & dynamodb-admin
- `terraform/` — código Terraform que cria S3 + Notification, SQS + DLQ, Lambda, DynamoDB e IAM
- `lambda/main.py` — código da Lambda (Python 3.10, usa `boto3`)
- `scripts/` — scripts `init_demo.sh`, `test_flow.sh`, `cleanup.sh`

---
