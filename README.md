# Do Zero ao MVP Serverless: AWS com Localstack e Terraform (DEVPIRA 2025)

![Logo DEVPIRA 2025](docs/img/Logo.svg) Repositório com todo o material de apoio, códigos e scripts da minha palestra **"Do Zero ao MVP Serverless: Construindo uma Aplicação AWS sem Gastar um Real"** apresentada no DEVPIRA Festival 2025, em Piracicaba-SP.

**Palestrante:** Rafael Rotiroti ([LinkedIn](https://www.linkedin.com/in/rotirotirafa))

O objetivo desta palestra é demonstrar como qualquer desenvolvedor pode criar, testar e validar arquiteturas _serverless_ complexas da AWS de forma 100% local, rápida e gratuita.

## O "Porquê" desta Palestra

* **Agilidade:** Teste e itere sua arquitetura em minutos, não horas.
* **Custo Zero:** Aprenda, estude para certificações e valide MVPs sem medo da fatura da AWS.
* **Autonomia:** Pare de depender de ambientes de desenvolvimento compartilhados e lentos.
* **Qualidade:** Teste o fluxo completo da sua aplicação (infra + código) antes de "commitar".

## Arquitetura do Nosso MVP

Neste projeto, construímos uma pipeline de processamento de pedidos assíncrona e desacoplada, usando os seguintes serviços (simulados localmente):

1.  **S3 Bucket:** Recebe um arquivo `pedido.json`.
2.  **SQS Queue:** Recebe uma notificação do S3 sobre o novo arquivo.
3.  **Lambda Function:** É acionada pela mensagem na fila SQS, processa o pedido.
4.  **DynamoDB Table:** Armazena o resultado do processamento.

![Diagrama da Arquitetura](https://caminho-para-seu-diagrama/diagrama.png) ---

## 🚀 Como Rodar este Projeto Localmente

Você só precisa ter **Docker**, **Terraform** e o **AWS CLI** instalados.

### 1. Clone o Repositório

```bash
git clone [https://github.com/rotirotirafa/localstack-aws-tf-local-devpira-2025.git](https://github.com/rotirotirafa/localstack-aws-tf-local-devpira-2025.git)
cd localstack-aws-tf-local-devpira-2025
```

### 2. Suba o Ambiente Localstack

Isso iniciará o container do Localstack com todos os serviços da AWS prontos para uso na porta `4566`.

```bash
docker-compose up -d
```

### 3. Aplique a Infraestrutura com Terraform

Vamos usar o `tflocal` (um wrapper do Terraform para o Localstack) para criar nossa infraestrutura.

Primeiro, instale o `tflocal` (se ainda não tiver):
```bash
pip install terraform-local
```

Agora, dentro da pasta `scripts/`, inicialize e aplique:
```bash
cleanup.sh

# Inicializa o Terraform
init_demo.sh

# Aplica e cria os recursos (S3, SQS, Lambda, DynamoDB)
test_flow.sh
```

**Pronto! Sua arquitetura AWS está no ar, rodando na sua máquina!**

*Nota sobre a Lambda:* O script do Terraform irá automaticamente zipar o código da pasta `lambda_src` e "deployar" na Lambda local.

### 4. Teste o Fluxo Completo!

Preparei um script que simula todo o processo:

```bash
cd ..
bash scripts/test_flow.sh
```

O que este script faz:
1.  Faz upload de um arquivo `pedido_teste.json` para o bucket S3.
2.  Consulta a fila SQS para mostrar a mensagem chegando (opcional).
3.  Aguarda alguns segundos para a Lambda processar.
4.  Consulta a tabela do DynamoDB e... **mostra o pedido processado!**

### 5. Limpando o Ambiente

Quando terminar de brincar, derrube tudo para não consumir recursos:

```bash
bash scripts/cleanup.sh
# ou
docker-compose down
```

---

## 📚 Material de Apoio

* **Artigo Original (Dev.to):** Este projeto é uma evolução da ideia que apresentei no artigo [Como usar Terraform + Localstack (com Docker)](https://dev.to/rotirotirafa/como-usar-terraform-localstack-com-docker-h44).
* **Slides da Palestra:** [SLIDES.pdf](SLIDES.pdf)
* **Documentação Oficial:**
    * [Localstack](https://localstack.cloud/)
    * [Terraform](https://www.terraform.io/)
    * [tflocal](https://github.com/localstack/terraform-local)

## Vamos nos Conectar!

Obrigado por assistir à palestra! Se você tiver dúvidas, feedbacks ou apenas quiser trocar uma ideia sobre tecnologia, me encontre:

* **LinkedIn:** [linkedin.com/in/rotirotirafa](https://www.linkedin.com/in/rotirotirafa)
* **GitHub:** [github.com/rotirotirafa](https://github.com/rotirotirafa)