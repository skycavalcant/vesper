# ADR-001: Terraform como ferramenta de Infrastructure as Code

*ADR-001: Terraform as Infrastructure as Code tool*

**Data:** 2026  
**Status:** Aceito

## Contexto

O Vesper precisa de uma ferramenta de Infrastructure as Code para provisionar e gerenciar todos os recursos AWS de forma consistente entre os ambientes (dev, prod).

As principais opções consideradas foram:
- AWS CloudFormation
- AWS CDK
- Terraform

*Vesper needs an Infrastructure as Code tool to provision and manage all AWS resources consistently across environments (dev, prod).*

*The main options considered were: AWS CloudFormation, AWS CDK, Terraform.*

---

## Decisão

Escolhi o **Terraform**.

*I chose **Terraform**.*

---

## Motivos

1. **Agnóstico de provider** — O Vesper é AWS-first hoje, mas sua arquitetura não deve estar presa a um único provedor cloud. O Terraform suporta AWS, GCP, Azure e outros com a mesma linguagem e workflow, preservando a opção de expandir sem reescrever o código de infraestrutura.

2. **Gerenciamento de estado explícito** — O Terraform mantém um state file que representa exatamente o que existe em cada ambiente. Isso torna possível detectar drift entre a infraestrutura declarada e o que está realmente rodando — uma capacidade crítica para uma plataforma de resiliência.

3. **Separação de responsabilidades** — Diferente do AWS CDK, o Terraform mantém o código de infraestrutura completamente separado do código de aplicação. Para o Rigel, onde decisões de infraestrutura são decisões arquiteturais, essa separação torna mais fácil e seguro raciocinar, revisar e auditar mudanças de infraestrutura.

4. **Maturidade e ecossistema** — O Terraform possui um provider AWS estável e bem documentado, além de um registry de módulos reutilizáveis. Para um projeto que precisa se mover rápido sem sacrificar confiabilidade, isso reduz o risco de encontrar casos de borda sem suporte.

---

1. *Provider agnostic — Vesper is AWS-first today, but its architecture should not be locked to a single cloud provider. Terraform supports AWS, GCP, Azure, and others with the same language and workflow, preserving the option to expand without rewriting infrastructure code.*

2. *Explicit state management — Terraform maintains a state file that represents exactly what exists in each environment. This makes it possible to detect drift between declared infrastructure and what is actually running — a critical capability for a resilience platform.*

3. *Separation of concerns — Unlike AWS CDK, Terraform keeps infrastructure code completely separate from application code. For Vesper, where infrastructure decisions are architectural decisions, this separation makes reasoning, reviewing, and auditing infrastructure changes easier and safer.*

4. *Maturity and ecosystem — Terraform has a stable, well-documented AWS provider and a registry of reusable modules. For a project that needs to move fast without sacrificing reliability, this reduces the risk of hitting unsupported edge cases.*

---

## Consequências

- Toda a infraestrutura é definida em arquivos `.tf` dentro de `/infra`
- Os módulos são reutilizáveis entre ambientes
- O state é armazenado remotamente no S3 com lock via DynamoDB (configurado por ambiente)
- CloudFormation e CDK não serão utilizados neste projeto

---

- *All infrastructure is defined in `.tf` files under `/infra`*
- *Modules are reusable across environments*
- *State is stored remotely in S3 with DynamoDB locking (configured per environment)*
- *CloudFormation and CDK will not be used in this project*
