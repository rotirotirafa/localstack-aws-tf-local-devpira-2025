# Contexto do Projeto: DEVPIRA 2025 - Do Zero ao MVP Serverless

## 🎯 Objetivo
Este projeto é uma demonstração para uma palestra técnica. O objetivo é criar uma arquitetura AWS Serverless completa que rode 100% localmente usando **Localstack**, mas que esteja pronta para ser implantada em **AWS Dev/Prod** usando o mesmo código Terraform.

## 🏗 Arquitetura
O fluxo de dados da aplicação é orientado a eventos:
1.  **S3 Bucket:** Recebe o upload de um arquivo `.json` (o pedido).
2.  **S3 Event Notification:** O bucket notifica uma fila SQS.
3.  **SQS Queue:** Armazena a mensagem (desacoplamento).
4.  **Lambda Function:** É acionada pelo evento da SQS, lê a mensagem, processa o pedido.
5.  **DynamoDB Table:** Armazena o resultado do processamento (Status: PROCESSADO).

## 🛠 Tech Stack
* **Orquestração:** Docker Compose.
* **Simulador Cloud:** Localstack (Imagem: `localstack/localstack:3`).
* **IaC:** Terraform (com wrapper `tflocal` para uso local).
* **Linguagem da Lambda:** Python 3.10 (usando `boto3`).
* **Scripts:** Bash (Ubuntu).

## 📂 Estrutura de Diretórios Obrigatória
```text
/
├── docker-compose.yml        # Configuração do Localstack
├── COPILOT_CONTEXT.md        # Este arquivo
├── lambda/                   # Código fonte da função
│   ├── main.py
│   └── requirements.txt
├── scripts/                  # Scripts de automação
│   ├── init_demo.sh          # Sobe docker e aplica terraform
│   ├── test_flow.sh          # Executa o teste de ponta a ponta
│   └── cleanup.sh            # Destroi infra e para containers
└── terraform/                # Código IaC
    ├── main.tf               # Recursos (S3, SQS, Lambda, Dynamo)
    ├── provider.tf           # Configuração AWS e Alias Localstack
    ├── variables.tf          # Declaração de variáveis
    ├── outputs.tf            # Outputs do Terraform
    └── environments/         # Variáveis por ambiente
        ├── local.tfvars      # Vars para Localstack
        ├── dev.tfvars        # Vars para AWS Dev
        └── prod.tfvars       # Vars para AWS Prod