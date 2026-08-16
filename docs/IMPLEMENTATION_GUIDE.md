# Vesper Watch - Guia de Implementação Completo

**Autora:** Kaysa Cavalcante  
**Data:** 2026-08-09  
**Fase:** Vesper Watch (MVP Completo)

---

## Visão Geral

Implementamos a **Fase 1 do Vesper**: um sistema completo de coleta de eventos de falhas de EC2 usando **Lambda + EventBridge + DynamoDB**.

**Fluxo:**
```
EC2 falha → EventBridge detecta → Lambda processa → DynamoDB armazena
```

---

## Estrutura Criada (25 arquivos)

```
vesper/
├── 📄 README.md                          # Documentação principal
├── 📄 CONTRIBUTING.md                    # Guia para colaboradores
├── 📄 SECURITY.md                        # Política de segurança
├── 📄 .gitignore                         # Arquivos ignorados pelo Git
├── 📄 requirements-dev.txt               # Dependências de desenvolvimento
├── 📄 pytest.ini                         # Configuração de testes
│
├── 📁 docs/
│   ├── adr/                              # Architecture Decision Records
│   │   ├── ADR-001-terraform.md
│   │   ├── ADR-002-python-lambda.md
│   │   └── ADR-003-step-functions.md
│   └── IMPLEMENTATION_GUIDE.md           # Este arquivo
│
├── 📁 modules/watch/                     # Módulo Vesper Watch
│   ├── README.md                         # Documentação do módulo
│   ├── src/
│   │   ├── collector.py                  # Lambda handler
│   │   └── requirements.txt              # Dependências Lambda
│   └── tests/
│       └── test_collector.py             # Testes unitários
│
├── 📁 infra/                             # Infraestrutura Terraform
│   ├── modules/watch/                    # Módulo Terraform reutilizável
│   │   ├── main.tf                       # Recursos principais
│   │   ├── iam.tf                        # Roles e políticas IAM
│   │   ├── variables.tf                  # Variáveis de entrada
│   │   └── outputs.tf                    # Valores de saída
│   └── environments/dev/                 # Ambiente de desenvolvimento
│       ├── main.tf                       # Configuração dev
│       ├── variables.tf                  # Variáveis dev
│       ├── outputs.tf                    # Outputs dev
│       └── terraform.tfvars.example      # Template de configuração
│
├── 📁 scripts/                           # Scripts de automação
│   ├── account-setup.sh                  # Configuração inicial AWS
│   ├── build-lambda.sh                   # Build do pacote Lambda
│   ├── deploy-dev.sh                     # Deploy completo
│   └── test-event.sh                     # Teste funcional
│
└── 📁 tests/
    └── integration/                      # Testes de integração (futuro)
```

---

## Explicação Arquivo por Arquivo

### 📄 Documentação Raiz

#### `README.md` (atualizado)
**O que é:** Documentação principal do projeto  
**Por quê:** Ponto de entrada para qualquer pessoa que abre o repositório  
**Conteúdo adicionado:**
- Seção "Quick Start" com comandos práticos
- Seção "Development" mostrando estrutura implementada
- Roadmap marcando Vesper Watch como ✅ COMPLETED
- Instruções de deploy e testes

**Melhoria possível:** Adicionar badges do GitHub (build status, coverage)

---

#### `CONTRIBUTING.md` (novo)
**O que é:** Guia para colaboradores (especialmente o coautor)  
**Por quê:** Define claramente as regras de contribuição  
**Conteúdo:**
- Workflow de branches (feature/*, docs/*, security/*)
- Padrão Conventional Commits
- Template de Pull Request
- Checklist de segurança
- Padrões de código (Python/Terraform)
- Processo de aprovação

**Por que escolhemos isso:**
- Você mencionou que **tudo precisa da sua aprovação**
- Coautor focado em **documentação e segurança**
- CONTRIBUTING.md é padrão open-source

**Alternativas consideradas:**
- GitHub Wiki (menos formal)
- Issues templates (mais fragmentado)
- ❌ Rejeitadas porque CONTRIBUTING.md centraliza tudo

**O que faria diferente:**
- Adicionar exemplos de PRs bem-feitos
- Link para code review checklist

---

#### `SECURITY.md` (novo)
**O que é:** Política de segurança e guia de revisão  
**Por quê:** Seu coautor é analista de segurança - precisa de diretrizes claras  
**Conteúdo:**
- Como reportar vulnerabilidades (email privado)
- Princípios de segurança (Least Privilege, Defense in Depth)
- Checklist de segurança para PRs
- Áreas específicas de revisão (IAM, Lambda, Terraform)
- Vulnerabilidades comuns a evitar
- Ferramentas de SAST recomendadas

**Por que escolhemos isso:**
- GitHub reconhece `SECURITY.md` como arquivo especial
- Centraliza conhecimento de segurança para o coautor
- Previne vulnerabilidades comuns em AWS

**Melhoria possível:**
- Adicionar threat model específico do Vesper
- Runbook de resposta a incidentes

---

#### `.gitignore` (atualizado)
**O que mudou:** Adicionei mais padrões  
**Por quê:** Prevenir commits acidentais de:
- Arquivos de build (`build/`, `*.zip`)
- Terraform state (`.terraform/`, `*.tfstate`)
- Dependências Python (`__pycache__`, `.pytest_cache`)
- Credenciais (`*.pem`, `.env`, `credentials.json`)

**Por que importa:**
- ❌ Terraform state pode conter secrets
- ❌ `.env` pode ter API keys
- ❌ `.pem` são chaves privadas

**Alternativa:** `.gitattributes` para LFS (arquivos grandes) - não necessário agora

---

#### `requirements-dev.txt` (novo)
**O que é:** Dependências para desenvolvimento local  
**Por quê:** Separa dependências de dev vs. produção  
**Conteúdo:**
- `pytest` - framework de testes
- `pytest-cov` - coverage de código
- `moto` - mock de serviços AWS (testes sem custo)
- `black` - formatação automática
- `pylint` / `flake8` - linting
- `mypy` - type checking

**Por que escolhemos isso:**
- **Produção** (Lambda): só `boto3` (minimalista)
- **Desenvolvimento**: ferramentas completas
- Reduz tamanho do pacote Lambda

**Melhoria possível:**
- Adicionar `pre-commit` para hooks automáticos
- `pip-audit` para scan de vulnerabilidades

---

#### `pytest.ini` (novo)
**O que é:** Configuração do pytest  
**Por quê:** Padroniza como testes rodam  
**Configurações:**
- `testpaths = modules tests` - onde procurar testes
- `--cov=modules` - medir coverage
- `--cov-report=html` - gerar relatório HTML
- Markers (`unit`, `integration`, `slow`)

**Por que escolhemos isso:**
- Permite rodar `pytest` sem argumentos
- Coverage automático
- Separa testes rápidos de lentos

**Alternativa:** `tox.ini` para múltiplos ambientes Python - overkill agora

---

### 📁 modules/watch/

#### `collector.py` (novo) - ⭐ CORE
**O que é:** Lambda function que processa eventos  
**Por quê:** Coração do Vesper Watch  

**Anatomia do código:**

```python
# 1. Imports
import boto3  # AWS SDK
from datetime import datetime
from typing import Dict, Any  # Type hints (mypy)

# 2. Cliente DynamoDB
dynamodb = boto3.resource('dynamodb')
table_name = os.environ.get('EVENTS_TABLE_NAME')  # Da env var
table = dynamodb.Table(table_name)

# 3. Handler principal
def lambda_handler(event: Dict[str, Any], context: Any):
    # Extrai metadados do evento EventBridge
    event_source = event.get('source')  # "aws.ec2"
    event_type = event.get('detail-type')  # "EC2 Instance State-change..."
    event_detail = event.get('detail', {})  # Detalhes específicos
    
    # Gera ID único (idempotência)
    event_id = f"{event_source}-{timestamp}-{instance_id}"
    
    # Armazena no DynamoDB
    item = {
        'event_id': event_id,
        'timestamp': timestamp,
        'source': event_source,
        'event_type': event_type,
        'detail': json.dumps(event_detail),  # JSON string
        'processed': False,  # Para Vesper Brain processar depois
        'created_at': datetime.utcnow().isoformat()
    }
    
    table.put_item(Item=item)
    
    return {'statusCode': 200, 'body': json.dumps({...})}
```

**Decisões técnicas:**

1. **Por que `boto3.resource()` e não `boto3.client()`?**
   - Resource é higher-level, mais Pythônico
   - `table.put_item()` vs `client.put_item(TableName=...)`
   - Alternativa: Client para operações low-level (batch writes)

2. **Por que `event_id` composto?**
   - Garante idempotência (mesmo evento = mesmo ID)
   - Evita duplicatas se EventBridge retentar
   - Formato: `source-timestamp-instance`

3. **Por que `processed: False`?**
   - Futuro: Vesper Brain vai buscar eventos não processados
   - Global Secondary Index (GSI) permite query eficiente

4. **Por que JSON.dumps(detail)?**
   - DynamoDB não aceita objetos nested ilimitados
   - String é mais flexível para mudanças futuras
   - Alternativa: Flatten o JSON (mais complexo)

**Tratamento de erros:**

```python
except ClientError as e:
    # Erro específico do DynamoDB
    error_msg = f"DynamoDB error: {e.response['Error']['Message']}"
    print(error_msg)  # CloudWatch Logs
    return {'statusCode': 500, 'body': ...}
```

- Separa `ClientError` (AWS) de `Exception` (genérico)
- Loga internamente, retorna mensagem genérica (segurança)
- **Não vaza** stack traces ao usuário

**O que faria diferente:**
- Adicionar **structured logging** (JSON logs)
- Validação mais rigorosa de `instance-id` (regex)
- Retry com exponential backoff para erros transientes
- Dead Letter Queue (DLQ) para eventos que falham

---

#### `requirements.txt` (novo)
**O que é:** Dependências da Lambda  
**Por quê:** Terraform precisa empacotar isso com o código  
**Conteúdo:**
```
boto3==1.34.144
botocore==1.34.144
```

**Por que escolhemos isso:**
- Versions pinadas (segurança + reprodutibilidade)
- `boto3` - AWS SDK Python
- `botocore` - dependência do boto3

**Alternativa:**
- Não incluir boto3 (AWS Lambda já tem)
- ❌ Problema: versão pode mudar sem aviso

**Melhoria:**
- `pip-compile` (pip-tools) para lock file
- Poetry para dependency management

---

#### `test_collector.py` (novo)
**O que é:** Testes unitários da Lambda  
**Por quê:** Valida lógica antes de deploy  

**Estrutura:**

```python
# 1. Fixtures (dados de teste reutilizáveis)
@pytest.fixture
def sample_ec2_event():
    return {...}  # Evento real do EventBridge

@pytest.fixture
def mock_dynamodb_table():
    # Mock do DynamoDB (sem custo AWS)
    with patch('modules.watch.src.collector.table') as mock:
        yield mock

# 2. Testes
def test_lambda_handler_success(sample_ec2_event, mock_dynamodb_table):
    response = lambda_handler(sample_ec2_event, context)
    
    assert response['statusCode'] == 200
    mock_dynamodb_table.put_item.assert_called_once()

def test_lambda_handler_stores_correct_data(...):
    # Valida estrutura dos dados salvos
    call_args = mock_dynamodb_table.put_item.call_args
    stored_item = call_args.kwargs['Item']
    
    assert stored_item['source'] == 'aws.ec2'
    assert stored_item['processed'] is False
```

**Por que escolhemos isso:**
- **Fixtures** evitam repetição de código
- **Mocking** permite testar sem AWS
- **Assertions** validam comportamento esperado

**Coverage:**
- ✅ Sucesso (happy path)
- ✅ Campos faltando (`detail` vazio)
- ✅ Erros DynamoDB
- ✅ Idempotência (mesmo event_id)

**O que faria diferente:**
- Testes de integração com DynamoDB Local
- Testes de performance (milhares de eventos)
- Property-based testing (Hypothesis)

---

#### `README.md` (módulo)
**O que é:** Documentação específica do Vesper Watch  
**Por quê:** Módulo pode ser usado isoladamente  
**Conteúdo:**
- Visão geral da arquitetura
- Comandos de desenvolvimento
- Schema dos eventos
- Considerações de segurança

**Por que separado do README raiz:**
- README raiz = visão geral do projeto
- README módulo = detalhes de implementação
- Permite evoluir módulos independentemente

---

### 📁 infra/modules/watch/

#### `main.tf` (novo) - ⭐ INFRASTRUCTURE CORE
**O que é:** Define todos os recursos AWS  
**Por quê:** Infrastructure as Code (Terraform)  

**Recursos criados:**

##### 1. DynamoDB Table
```hcl
resource "aws_dynamodb_table" "events" {
  name         = "${var.project_name}-events-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"  # On-demand
  hash_key     = "event_id"
  
  attribute {
    name = "event_id"
    type = "S"  # String
  }
  
  global_secondary_index {
    name     = "ProcessedIndex"
    hash_key = "processed"
    range_key = "timestamp"
  }
  
  ttl {
    attribute_name = "ttl"
    enabled        = true
  }
}
```

**Decisões:**

- **PAY_PER_REQUEST** vs **PROVISIONED**:
  - On-demand: paga por request (melhor para dev)
  - Provisioned: capacidade fixa (mais barato em prod)
  - Escolhemos: PAY_PER_REQUEST para dev (sem surpresas de custo)

- **GSI (Global Secondary Index)**:
  - Por quê: Vesper Brain vai buscar `WHERE processed = false`
  - Sem GSI: teria que fazer SCAN (lento e caro)
  - Com GSI: QUERY eficiente

- **TTL (Time To Live)**:
  - Eventos expiram automaticamente
  - Reduz custos de storage
  - Exemplo: eventos > 30 dias deletados

**Alternativa:**
- RDS/Aurora (SQL) - mais caro, overkill
- S3 + Athena - para analytics, não operacional

---

##### 2. Lambda Function
```hcl
resource "aws_lambda_function" "collector" {
  filename      = var.lambda_zip_path  # build/watch-lambda.zip
  function_name = "${var.project_name}-watch-collector-${var.environment}"
  role          = aws_iam_role.lambda_role.arn
  handler       = "collector.lambda_handler"
  runtime       = "python3.12"
  timeout       = 30
  memory_size   = 256
  
  environment {
    variables = {
      EVENTS_TABLE_NAME = aws_dynamodb_table.events.name
    }
  }
}
```

**Decisões:**

- **Python 3.12**: Versão mais recente (ADR-002)
- **Timeout 30s**: Suficiente para DynamoDB write
- **Memory 256MB**: Mínimo recomendado para boto3
- **Env var**: Nome da tabela dinâmico (dev vs prod)

**source_code_hash:**
- Garante que Lambda só atualiza se código mudou
- Evita deploys desnecessários

---

##### 3. CloudWatch Log Group
```hcl
resource "aws_cloudwatch_log_group" "lambda_logs" {
  name              = "/aws/lambda/${aws_lambda_function.collector.function_name}"
  retention_in_days = 7
}
```

**Por quê:**
- Lambda cria log group automaticamente SEM retenção
- Sem retenção = logs infinitos = $ crescendo
- 7 dias suficiente para dev (prod seria 30-90 dias)

---

##### 4. EventBridge Rules
```hcl
resource "aws_cloudwatch_event_rule" "ec2_state_change" {
  event_pattern = jsonencode({
    source      = ["aws.ec2"]
    detail-type = ["EC2 Instance State-change Notification"]
    detail = {
      state = ["stopped", "stopping", "terminated", "terminating"]
    }
  })
}

resource "aws_cloudwatch_event_target" "lambda" {
  rule = aws_cloudwatch_event_rule.ec2_state_change.name
  arn  = aws_lambda_function.collector.arn
}
```

**Decisões:**

- **2 regras separadas**:
  1. EC2 state changes (stopped, terminated)
  2. AWS Health events (status check failed)
  
- **Por quê separar:**
  - Event patterns diferentes
  - Facilita debug (qual regra disparou?)
  - Pode desativar uma sem afetar outra

**Alternativa:**
- Regra única com OR - menos granular

---

##### 5. Lambda Permission
```hcl
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.collector.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2_state_change.arn
}
```

**Por quê:**
- Lambda por padrão não aceita invocações externas
- Isso autoriza especificamente EventBridge
- `source_arn` garante que só ESSA regra pode invocar

---

#### `iam.tf` (novo) - ⭐ SECURITY CORE
**O que é:** Roles e políticas IAM  
**Por quê:** Princípio de Least Privilege  

**Estrutura:**

##### 1. Lambda Execution Role
```hcl
resource "aws_iam_role" "lambda_role" {
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}
```

**O que isso faz:**
- Permite que **apenas** o serviço Lambda assuma esse role
- Se alguém tentar assumir esse role manualmente → ❌ negado

---

##### 2. CloudWatch Logs Policy
```hcl
resource "aws_iam_role_policy" "lambda_logging" {
  policy = jsonencode({
    Statement = [{
      Effect = "Allow"
      Action = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]
      Resource = "arn:aws:logs:${var.aws_region}:${account_id}:log-group:/aws/lambda/${function_name}:*"
    }]
  })
}
```

**Decisões de segurança:**

- ✅ ARN específico (não `Resource: "*"`)
- ✅ Apenas 3 ações necessárias
- ✅ Apenas log group dessa Lambda

**Alternativa insegura:**
```hcl
# ❌ NUNCA FAZER ISSO
Action   = "logs:*"
Resource = "*"
```

---

##### 3. DynamoDB Policy
```hcl
resource "aws_iam_role_policy" "lambda_dynamodb" {
  policy = jsonencode({
    Action = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:UpdateItem",
      "dynamodb:Query"
    ]
    Resource = [
      aws_dynamodb_table.events.arn,
      "${aws_dynamodb_table.events.arn}/index/*"  # GSI
    ]
  })
}
```

**Decisões de segurança:**

- ✅ Apenas 4 ações (não `Scan`, `DeleteItem`)
- ✅ Apenas essa tabela
- ✅ Inclui GSI (`/index/*`)

**Por que não `Scan`:**
- Scan é lento e caro
- Query é suficiente com GSI
- Reduz blast radius

---

#### `variables.tf` (novo)
**O que é:** Inputs do módulo Terraform  
**Por quê:** Torna módulo reutilizável  

**Variáveis:**

```hcl
variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be dev or prod."
  }
}

variable "log_retention_days" {
  type    = number
  default = 7
  validation {
    condition     = contains([1, 3, 5, 7, 14, ...], var.log_retention_days)
    error_message = "Log retention must be valid CloudWatch value."
  }
}
```

**Por que validations:**
- Previne erros antes do `terraform apply`
- `environment = "development"` → ❌ erro imediato
- Documentação integrada (quais valores são válidos)

---

#### `outputs.tf` (novo)
**O que é:** Valores exportados do módulo  
**Por quê:** Outros módulos/scripts precisam desses valores  

**Outputs:**
```hcl
output "lambda_function_name" {
  value = aws_lambda_function.collector.function_name
}
```

**Usado em:**
- `test-event.sh` pega nome da Lambda
- Futuros módulos podem referenciar
- `terraform output` mostra valores

---

### 📁 infra/environments/dev/

#### `main.tf` (novo)
**O que é:** Instancia o módulo watch para DEV  
**Por quê:** Separa configurações dev vs prod  

```hcl
provider "aws" {
  region = "us-east-1"
  default_tags {
    Project     = "Vesper"
    Environment = "dev"
  }
}

module "watch" {
  source                        = "../../modules/watch"
  environment                   = "dev"
  log_retention_days            = 7
  enable_point_in_time_recovery = false  # Dev não precisa
}
```

**Por que módulo:**
- DRY (Don't Repeat Yourself)
- `infra/environments/prod/` vai usar mesmo módulo
- Mudança no módulo → aplica em todos ambientes

---

#### `terraform.tfvars.example` (novo)
**O que é:** Template de configuração  
**Por quê:** Não commitamos `terraform.tfvars` (pode ter secrets)  

**Uso:**
```bash
cp terraform.tfvars.example terraform.tfvars
# Editar terraform.tfvars com valores reais
terraform apply
```

---

### 📁 scripts/

#### `build-lambda.sh` (novo)
**O que é:** Cria pacote ZIP da Lambda  
**Por quê:** Terraform precisa de ZIP pronto  

**O que faz:**
```bash
# 1. Limpa build anterior
rm -rf build/
mkdir -p build/package

# 2. Copia código
cp collector.py build/package/

# 3. Instala dependências
pip install -r requirements.txt -t build/package/

# 4. Cria ZIP
cd build/package
zip -r ../watch-lambda.zip .
```

**Por que não usar Terraform diretamente:**
- Terraform `archive_file` não instala pip packages
- Alternativa: SAM, Serverless Framework (overkill)

**Melhoria:**
- Docker build (ambiente consistente)
- Cache de dependências

---

#### `deploy-dev.sh` (novo)
**O que é:** Deploy completo (build + Terraform)  
**Por quê:** Um comando faz tudo  

**Passos:**
```bash
bash build-lambda.sh  # Build
terraform init        # Download providers
terraform apply       # Deploy
```

**Melhoria:**
- `terraform plan` antes de `apply`
- Confirmação manual

---

#### `test-event.sh` (novo)
**O que é:** Envia evento de teste para Lambda  
**Por quê:** Valida que deploy funcionou  

**Como funciona:**
```bash
# 1. Pega nome da Lambda do Terraform
FUNCTION_NAME=$(terraform output -raw lambda_function_name)

# 2. Cria evento de teste JSON
TEST_EVENT=$(cat <<EOF
{
  "source": "aws.ec2",
  "detail": {"instance-id": "i-test123"}
}
EOF
)

# 3. Invoca Lambda
aws lambda invoke --function-name $FUNCTION_NAME --payload "$TEST_EVENT" output.json

# 4. Consulta DynamoDB
aws dynamodb scan --table-name $TABLE_NAME
```

---

## Decisões de Design Principais

### 1. Por que Terraform e não CloudFormation?
**Resposta:** ADR-001
- Multi-cloud (não lock-in AWS)
- State management explícito
- Ecossistema maduro

### 2. Por que Python e não Go/Node?
**Resposta:** ADR-002
- Boto3 é o SDK mais completo
- Ecossistema AWS é Python-first
- Legibilidade para lógica complexa

### 3. Por que separar módulos Terraform?
**Resposta:** Reutilização
- `infra/modules/watch/` é genérico
- `infra/environments/dev/` configura para dev
- `infra/environments/prod/` vai reusar o módulo

### 4. Por que DynamoDB e não RDS?
**Resposta:** Custo e escala
- RDS mínimo: ~$15/mês (sempre ligado)
- DynamoDB: $0 se baixo volume
- Auto-scaling nativo

### 5. Por que EventBridge e não SQS?
**Resposta:** Event-driven
- EventBridge filtra eventos (event pattern)
- SQS precisa polling ou Lambda trigger
- EventBridge é nativo para eventos AWS

---

## O Que Podemos Melhorar

### Curto Prazo (1-2 semanas)

1. **CI/CD Pipeline**
   ```yaml
   # .github/workflows/test.yml
   - run: pytest
   - run: terraform fmt -check
   - run: bandit -r modules/
   ```

2. **Pre-commit Hooks**
   ```yaml
   # .pre-commit-config.yaml
   - id: black
   - id: terraform-fmt
   - id: detect-secrets
   ```

3. **Testes de Integração**
   - LocalStack (AWS local)
   - DynamoDB Local
   - `pytest -m integration`

4. **Structured Logging**
   ```python
   logger.info("Event received", extra={
       "event_id": event_id,
       "source": event_source
   })
   ```

### Médio Prazo (1-3 meses)

5. **Dead Letter Queue (DLQ)**
   - Eventos que falham 3x → SQS DLQ
   - Manual review de falhas

6. **Metrics e Alertas**
   - CloudWatch Metric Filter
   - SNS alert se > 10 erros/min

7. **Terraform Remote State**
   ```hcl
   backend "s3" {
     bucket  = "rigel-tfstate"
     key     = "dev/watch.tfstate"
     encrypt = true
   }
   ```

8. **Input Validation**
   ```python
   from pydantic import BaseModel
   
   class EC2Event(BaseModel):
       source: str
       detail: dict
   ```

### Longo Prazo (3-6 meses)

9. **Multi-region Deployment**
   - EventBridge → Lambda em us-east-1 E us-west-2
   - DynamoDB Global Tables

10. **Cost Optimization**
    - DynamoDB Reserved Capacity (prod)
    - Lambda Reserved Concurrency
    - S3 Lifecycle (logs → Glacier)

11. **Observability Completa**
    - AWS X-Ray (tracing)
    - CloudWatch Insights
    - Grafana dashboards

12. **Security Hardening**
    - VPC Lambda (se precisar recursos privados)
    - Secrets Manager (se precisar credenciais externas)
    - KMS encryption (tabela DynamoDB)

---

## O Que Eu Faria Diferente

### Se Fosse Começar Hoje

1. **Monorepo desde o início**
   ```
   rigel/
   ├── services/watch/     # Cada módulo isolado
   ├── services/brain/
   └── infrastructure/     # Terraform separado
   ```

2. **Poetry em vez de pip**
   - Gerenciamento de dependências mais robusto
   - Lock file automático

3. **Terraform Workspaces**
   ```bash
   terraform workspace new dev
   terraform workspace new prod
   ```

4. **AWS CDK em vez de Terraform**
   - Se 100% AWS (não multi-cloud)
   - Código TypeScript/Python vs HCL
   - ❌ Mas violaria ADR-001

5. **Step Functions desde início**
   - Mesmo para Lambda única
   - Facilita adicionar etapas depois

### Se Fosse Produção Real

1. **Compliance desde dia 1**
   - Tagging obrigatório (CostCenter, Owner)
   - GuardDuty + SecurityHub
   - AWS Config Rules

2. **Disaster Recovery**
   - Backup cross-region
   - Runbook de restore
   - RTO/RPO definidos

3. **FinOps**
   - Budget alerts granulares
   - Cost allocation tags
   - Rightsizing contínuo

---

## Próximos Passos

### Imediatos (você pode fazer agora)

```bash
# 1. Instalar dependências
pip install -r requirements-dev.txt

# 2. Rodar testes
pytest -v

# 3. Deploy (se tiver AWS configurado)
./scripts/deploy-dev.sh

# 4. Testar
./scripts/test-event.sh
```

### Coautor de Segurança

1. Revisar `infra/modules/watch/iam.tf`
   - IAM policies muito permissivas?
2. Adicionar testes de segurança
   - `bandit -r modules/`
3. Documentar threat model
4. Propor melhorias em `SECURITY.md`

### Próximas Features

1. **Vesper Repair** (Fase 2)
   - Step Functions workflow
   - Lambda para restart EC2
   - SNS notifications

2. **Vesper Brain** (Fase 3)
   - Bedrock integration
   - Prompt engineering
   - Confidence scoring

---

## Perguntas Frequentes

**P: Por que 25 arquivos para uma Lambda simples?**  
R: Não é "só uma Lambda". É:
- Infraestrutura reproduzível (Terraform)
- Testes automatizados (pytest)
- Documentação completa (READMEs, ADRs)
- Scripts de automação (deploy)
- Segurança desde o início (IAM, SECURITY.md)

**P: Não é over-engineering?**  
R: Para produção, isso é o mínimo. Você está aprendendo **boas práticas desde o início**, não "quick and dirty" que vai precisar refazer depois.

**P: Quanto custa rodar isso?**  
R: 
- DynamoDB: $0 (free tier: 25 GB)
- Lambda: $0 (free tier: 1M requests/mês)
- EventBridge: $0 (free tier)
- **Custo real em dev: ~$0.50/mês**

**P: Posso usar isso em produção?**  
R: Quase! Faltaria:
- Remote Terraform state
- DynamoDB point-in-time recovery
- CloudWatch alarms
- Encryption KMS

---

**Dúvidas sobre algum arquivo específico? Me avise!**
