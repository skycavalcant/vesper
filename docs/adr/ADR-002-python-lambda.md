# ADR-002: Python como runtime das Lambdas

*ADR-002: Python as Lambda runtime*

**Data:** 2026  
**Status:** Aceito

## Contexto

A lógica central do Rigel roda em funções AWS Lambda. Precisávamos escolher uma linguagem de runtime.

As principais opções consideradas foram:
- Python
- JavaScript (Node.js)
- Go

*Rigel's core logic runs in AWS Lambda functions. We needed to choose a runtime language.*

*The main options considered were: Python, JavaScript (Node.js), Go.*

---

## Decisão

Escolhi **Python 3.12**.

*I chose **Python 3.12**.*

---

## Motivos

1. **Ecossistema AWS** — Python é a linguagem nativa do ecossistema AWS. Boto3, SAM, CDK, scripts de automação — tudo vive em Python primeiro. É a linguagem que a própria AWS utiliza em exemplos de documentação e ferramentas oficiais.

2. **Maturidade do Boto3** — O AWS SDK para Python (Boto3) é o mais completo, melhor documentado e mais ativamente mantido SDK para AWS. Cada serviço AWS possui um client no Boto3.

3. **Legibilidade** — As funções Lambda do Rigel contêm lógica de decisão complexa. A legibilidade do Python torna essa lógica mais fácil de raciocinar, testar e documentar.

4. **Alinhamento estratégico** — Python é a linguagem padrão para automação cloud, scripts DevOps e engenharia de dados. Adotá-la aqui é uma escolha técnica deliberada, alinhada ao perfil de Solutions Architect — não uma questão de conveniência.

---

1. *AWS ecosystem — Python is the native language of the AWS ecosystem. Boto3, SAM, CDK, automation scripts — everything lives in Python first. It is the language AWS itself uses in its documentation examples and official tooling.*

2. *Boto3 maturity — The AWS SDK for Python (Boto3) is the most complete, best documented, and most actively maintained SDK for AWS. Every AWS service has a Boto3 client.*

3. *Readability — Rigel's Lambda functions contain complex decision logic. Python's readability makes that logic easier to reason about, test, and document.*

4. *Strategic alignment — Python is the standard language for cloud automation, DevOps scripting, and data engineering. Adopting it here is a deliberate technical choice aligned with the Solutions Architect skillset, not a matter of convenience.*

---

## Consequências

- Todas as funções Lambda são escritas em Python 3.12
- Boto3 é o AWS SDK utilizado em todo o projeto
- Dependências são gerenciadas com `requirements.txt` por módulo
- Node.js não será utilizado como runtime Lambda neste projeto

---

- *All Lambda functions are written in Python 3.12*
- *Boto3 is the AWS SDK used throughout*
- *Dependencies are managed with `requirements.txt` per module*
- *Node.js will not be used for Lambda runtime in this project*
