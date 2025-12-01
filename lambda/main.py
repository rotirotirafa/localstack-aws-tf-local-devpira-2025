import os
import json
import boto3
import uuid
import urllib.parse

# 1. Inicializa os clientes fora do handler (boa prática)
dynamodb = boto3.resource('dynamodb')

# Pega o nome da tabela do DynamoDB da variável de ambiente que o Terraform injetou.
TABLE_NAME = os.environ.get('DYNAMO_TABLE_NAME')
if not TABLE_NAME:
    raise ValueError("Variável de ambiente 'DYNAMO_TABLE_NAME' não definida.")

table = dynamodb.Table(TABLE_NAME)


def lambda_handler(event, context):
    """
    Handler principal da Lambda.
    Recebe um lote de mensagens do SQS.
    """
    print("Evento recebido:", json.dumps(event))
    
    # O SQS envia um lote de mensagens em 'Records'
    for sqs_record in event['Records']:
        try:
            # A mensagem real do S3 está dentro do 'body' da mensagem SQS
            # O 'body' é uma string JSON, então precisamos fazer o parse
            s3_event_body = json.loads(sqs_record['body'])
            
            # Agora sim, pegamos o registro do S3
            for s3_record in s3_event_body['Records']:
            
                # 3. Extrai as informações do evento S3
                bucket_name = s3_record['s3']['bucket']['name']
                object_key = s3_record['s3']['object']['key']
                
                # O 'key' pode vir com codificação de URL (ex: espaços como '+')
                object_key = urllib.parse.unquote_plus(object_key)
                
                print(f"Processando arquivo: {object_key} do bucket: {bucket_name}")

                # 4. Lógica de "Processamento" (Simples)
                # Usamos o nome do arquivo (sem o .json) como ID do pedido
                pedido_id = os.path.splitext(os.path.basename(object_key))[0]

                # 5. Salva o resultado no DynamoDB
                item = {
                    'pedidoId': pedido_id,
                    'nomeArquivo': object_key,
                    'bucket': bucket_name,
                    'status': 'PROCESSADO'
                }
                
                table.put_item(Item=item)
                
                print(f"Pedido {pedido_id} salvo com sucesso no DynamoDB.")

        except Exception as e:
            print(f"Erro ao processar registro: {e}")
            raise e

    return {
        'statusCode': 200,
        'body': json.dumps('Processamento concluído com sucesso!')
    }
