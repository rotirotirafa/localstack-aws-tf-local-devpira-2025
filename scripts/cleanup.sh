#!/bin/bash
set -e
echo "🧹 Limpando o ambiente..."
cd "$(dirname "$0")/.."

cd terraform
tflocal destroy -var-file="environments/local.tfvars" -auto-approve
cd ..
docker compose down -v
echo "✅ Limpeza concluída."