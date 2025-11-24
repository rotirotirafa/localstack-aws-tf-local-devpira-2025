#!/bin/bash
set -e

echo "🚀 Iniciando o ambiente Localstack..."
cd "$(dirname "$0")/.."

docker compose up -d

echo "⏳ Aguardando 5 segundos para garantir que o Localstack está respondendo..."
sleep 5

echo "🏗️  Aplicando a infraestrutura com Terraform..."
cd terraform

# Inicializa e aplica usando o perfil 'local'
tflocal init
tflocal apply -var-file="environments/local.tfvars" -auto-approve

echo "✅ Ambiente pronto! Infraestrutura criada."