# Rigel
**Detecção e recuperação autônoma de falhas. Automaticamente.**

*Autonomous failure detection and recovery. Automatically.*

O Rigel é uma plataforma autônoma de resiliência para infraestrutura AWS. Ele detecta falhas, diagnostica causa raiz, executa ações de recuperação e reporta o que aconteceu — sem intervenção humana.

*Rigel is an autonomous resilience platform for AWS infrastructure. It detects failures, diagnoses root causes, executes recovery actions, and reports what happened — without human intervention.*

> Não é monitoramento. Não é backup. É um sistema imunológico para a sua cloud.
>
> *Not monitoring. Not backup. An immune system for your cloud.*

---

## O Problema

```
Hoje:                           Com o Rigel:

Aplicação rodando               Falha detectada
       |                               |
     Falha                       Diagnóstico
       |                               |
Alguém acorda às 3h             Decisão (com confidence score)
       |                               |
   Investiga                    Recuperação automática
       |                               |
    Corrige                     Relatório do incidente
```

---

## Arquitetura

```
                    AWS Account
                         |
                    RIGEL AGENT
                         |
           ------------------------------
           |                            |
      Rigel Watch                 Rigel Brain
   (Coletor de Eventos)      (Motor de Decisão)
           |                            |
           ------------------------------
                         |
                   Rigel Repair
                         |
           ------------------------------
           |              |             |
         Lambda          ECS         Route53
           |              |             |
        Restart         Scale        Failover
                         |
                   Rigel Report
                         |
                     Dashboard
```

---

## Módulos

| Módulo | Status | Descrição |
|---|---|---|
| **Rigel Watch** | Em andamento | Coleta eventos do CloudWatch + EventBridge<br>*Collects events from CloudWatch + EventBridge* |
| **Rigel Brain** | Planejado | Diagnostica causa raiz usando AWS Bedrock<br>*Diagnoses root cause using AWS Bedrock* |
| **Rigel Repair** | Planejado | Executa ações de recuperação de forma autônoma<br>*Executes recovery actions autonomously* |
| **Rigel Report** | Planejado | Gera relatórios de incidente e dashboard<br>*Generates incident reports and dashboard* |

---

## Cenários Cobertos

- **Falha de EC2** → remove do Load Balancer, sobe uma nova instância, restaura a configuração
- **RDS indisponível** → ativa a réplica, atualiza o endpoint, alerta o time
- **Região degradada** → failover via Route53 para a região secundária
- **Anomalia de custo** → detecta criação anormal de recursos, bloqueia o scaling

- *EC2 failure → removes from Load Balancer, launches new instance, restores config*
- *RDS unavailable → activates replica, updates endpoint, alerts team*
- *Region degraded → Route53 failover to secondary region*
- *Cost anomaly → detects abnormal resource creation, blocks scaling*

---

## Stack Técnica

| Camada | Tecnologia |
|---|---|
| Infrastructure as Code | Terraform |
| Runtime das Lambdas | Python 3.12 |
| Barramento de eventos | EventBridge |
| Orquestração | Step Functions |
| Armazenamento | DynamoDB |
| Observabilidade | CloudWatch |
| IA/Diagnóstico | AWS Bedrock (Claude) |
| Failover de DNS | Route53 |

---

## Estrutura do Repositório

```
rigel/
├── modules/
│   ├── watch/        # Coleta de eventos
│   ├── brain/        # Diagnóstico por IA
│   ├── repair/       # Ações de recuperação
│   └── report/       # Relatório de incidentes
├── infra/
│   ├── modules/      # Módulos Terraform reutilizáveis
│   └── environments/ # Configs de dev / prod
├── docs/
│   ├── adr/          # Architecture Decision Records
│   └── diagrams/     # Diagramas de arquitetura
├── scripts/          # Utilitários de dev e teste local
└── tests/            # Testes de integração
```

---

## Quick Start

### Prerequisites

- AWS Account with CLI configured
- Terraform >= 1.0
- Python 3.12
- pip

### Deploy Rigel Watch (Development)

```bash
# 1. Install development dependencies
pip install -r requirements-dev.txt

# 2. Run tests
pytest

# 3. Deploy to AWS
./scripts/deploy-dev.sh

# 4. Test with a sample event
./scripts/test-event.sh
```

### Manual Deployment Steps

```bash
# Build Lambda package
./scripts/build-lambda.sh

# Deploy infrastructure
cd infra/environments/dev
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

---

## Development

### Project Structure

```
rigel/
├── modules/watch/         # ✅ IMPLEMENTED
│   ├── src/              # Lambda functions
│   └── tests/            # Unit tests
├── infra/                # ✅ IMPLEMENTED
│   ├── modules/watch/    # Terraform module
│   └── environments/dev/ # Dev environment
└── scripts/              # ✅ IMPLEMENTED
    ├── build-lambda.sh
    ├── deploy-dev.sh
    └── test-event.sh
```

### Running Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=modules --cov-report=html

# Run only unit tests
pytest -m unit

# Run specific test file
pytest modules/watch/tests/test_collector.py -v
```

---

## Roadmap

- [x] Definição do projeto e arquitetura
- [x] **Rigel Watch — pipeline de coleta de eventos** ✅ **CONCLUÍDO**
- [ ] Rigel Repair v1 — auto-recuperação de EC2
- [ ] Rigel Repair v2 — failover de RDS
- [ ] Rigel Repair v3 — failover multi-region
- [ ] Rigel Brain — diagnóstico por IA com Bedrock
- [ ] Rigel Report — dashboard e relatórios de incidente

- *[x] Project definition and architecture*
- *[x] Rigel Watch — event collection pipeline ✅ COMPLETED*
- *[ ] Rigel Repair v1 — EC2 auto-recovery*
- *[ ] Rigel Repair v2 — RDS failover*
- *[ ] Rigel Repair v3 — multi-region failover*
- *[ ] Rigel Brain — Bedrock AI diagnosis*
- *[ ] Rigel Report — dashboard and incident reports*

---

## Architecture Decision Records

Todas as decisões arquiteturais estão documentadas em [`/docs/adr`](/docs/adr).

*All architectural decisions are documented in [`/docs/adr`](/docs/adr).*

---

## Como Contribuir

As convenções de branch, commit e documentação estão em [`CONTRIBUTING.md`](CONTRIBUTING.md).

*Branch, commit, and documentation conventions are in [`CONTRIBUTING.md`](CONTRIBUTING.md).*

---

## Autor

Construído por um Solutions Architect em formação.
AWS Certified Cloud Practitioner | SAA-C03 em andamento.

*Built by a Solutions Architect in training.*
*AWS Certified Cloud Practitioner | SAA-C03 in progress.*
