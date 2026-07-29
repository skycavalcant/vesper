# ADR-003: Step Functions para orquestração de recuperação

*ADR-003: Step Functions for recovery orchestration*

**Data:** 2026  
**Status:** Aceito

## Contexto

Os workflows de repair do Rigel (recuperação de EC2, failover de RDS, failover multi-region) envolvem múltiplas etapas sequenciais que podem falhar independentemente.

As opções consideradas foram:
- Uma única função Lambda com todas as etapas
- Múltiplas Lambdas encadeadas via SQS
- AWS Step Functions

*Rigel's repair workflows (EC2 recovery, RDS failover, multi-region failover) involve multiple sequential steps that can each fail independently.*

*The options considered were: a single Lambda function with all steps, multiple Lambdas chained via SQS, AWS Step Functions.*

---

## Decisão

Escolhi **AWS Step Functions**.

*I chose **AWS Step Functions**.*

---

## Motivos

1. **Cada etapa pode falhar independentemente** — Em um failover de RDS, as etapas são: detectar → verificar réplica → promover → atualizar endpoint → notificar. Se "atualizar endpoint" falhar, queremos fazer retry apenas dessa etapa, não reiniciar o processo inteiro.

2. **Workflow visual** — Step Functions fornece uma representação visual do workflow de recuperação. Isso é valioso para documentação, debugging e demonstração do projeto.

3. **Retry e tratamento de erros nativos** — Step Functions possui lógica de retry nativa, blocos catch e configuração de timeout por estado. Implementar isso em uma única Lambda seria complexo e propenso a erros.

4. **Trilha de auditoria** — Cada execução de um workflow do Step Functions é registrada com input/output por estado. Isso alimenta diretamente o Rigel Report.

5. **Alinhamento com SAA-C03** — Step Functions é um serviço central no exame AWS Solutions Architect. Usá-lo aqui reforça esse aprendizado com experiência prática.

---

1. *Each step can fail independently — In an RDS failover, the steps are: detect → verify replica → promote → update endpoint → notify. If "update endpoint" fails, we want to retry only that step, not restart the entire process.*

2. *Visual workflow — Step Functions provides a visual representation of the recovery workflow. This is valuable for documentation, debugging, and demonstrating the project.*

3. *Built-in retry and error handling — Step Functions has native retry logic, catch blocks, and timeout configuration per state. Implementing this in a single Lambda would be complex and error-prone.*

4. *Audit trail — Every execution of a Step Functions workflow is logged with input/output per state. This feeds directly into Rigel Report.*

5. *SAA-C03 alignment — Step Functions is a core service in the AWS Solutions Architect exam. Using it here reinforces that learning with practical experience.*

---

## Consequências

- Cada cenário de repair (EC2, RDS, multi-region) é uma state machine separada no Step Functions
- As funções Lambda são pequenas e focadas — uma função por ação
- As definições de workflow são armazenadas como JSON em ASL (Amazon States Language) em `/modules/repair`
- Recuperações simples de uma única etapa ainda podem usar Lambda diretamente, sem Step Functions

---

- *Each repair scenario (EC2, RDS, multi-region) is a separate Step Functions state machine*
- *Lambda functions are small and focused — one function per action*
- *Workflow definitions are stored as ASL (Amazon States Language) JSON in `/modules/repair`*
- *Simple single-step recoveries may still use Lambda directly without Step Functions*
