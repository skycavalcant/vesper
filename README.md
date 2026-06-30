# Rigel
**Autonomous failure detection and recovery. Automatically.**

Rigel is an autonomous resilience platform for AWS infrastructure. It detects failures, diagnoses root causes, executes recovery actions, and reports what happened — without human intervention.

> Not monitoring. Not backup. An immune system for your cloud.

---

## The Problem

```
Today:                          With Rigel:

Application running             Failure detected
       |                               |
     Failure                    Diagnosis
       |                               |
Someone wakes up at 3am         Decision (with confidence score)
       |                               |
  Investigates                  Automatic recovery
       |                               |
    Fixes                       Incident report
```

---

## Architecture

```
                    AWS Account
                         |
                    RIGEL AGENT
                         |
           ------------------------------
           |                            |
      Rigel Watch                 Rigel Brain
    (Event Collector)          (Decision Engine)
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

## Modules

| Module           | Status      | Description                                   |
|--------|---------|-------------|
| **Rigel Watch**  | In progress | Collects events from CloudWatch + EventBridge |
| **Rigel Brain**  | Planned     | Diagnoses root cause using AWS Bedrock        |
| **Rigel Repair** | Planned     | Executes recovery actions autonomously        |
| **Rigel Report** | Planned     | Generates incident reports and dashboard      |

---

## Scenarios Handled

- **EC2 failure** → removes from Load Balancer, launches new instance, restores config
- **RDS unavailable** → activates replica, updates endpoint, alerts team
- **Region degraded** → Route53 failover to secondary region
- **Cost anomaly** → detects abnormal resource creation, blocks scaling

---

## Tech Stack

| Layer                  | Technology           |
|------------------------|----------------------|
| Infrastructure as Code | Terraform            |
| Lambda runtime         | Python 3.12          |
| Event bus              | EventBridge          |
| Orchestration          | Step Functions       |
| Storage                | DynamoDB             |
| Observability          | CloudWatch           |
| AI/Diagnosis           | AWS Bedrock (Claude) |
| DNS Failover           | Route53              |

---

## Repository Structure

```
rigel/
├── modules/
│   ├── watch/        # Event collection
│   ├── brain/        # AI diagnosis
│   ├── repair/       # Recovery actions
│   └── report/       # Incident reporting
├── infra/
│   ├── modules/      # Reusable Terraform modules
│   └── environments/ # dev / prod configs
├── docs/
│   ├── adr/          # Architecture Decision Records
│   └── diagrams/     # Architecture diagrams
├── scripts/          # Local dev and test utilities
└── tests/            # Integration tests
```

---

## Roadmap

- [x] Project definition and architecture
- [ ] Rigel Watch — event collection pipeline
- [ ] Rigel Repair v1 — EC2 auto-recovery
- [ ] Rigel Repair v2 — RDS failover
- [ ] Rigel Repair v3 — Multi-region failover
- [ ] Rigel Brain — Bedrock AI diagnosis
- [ ] Rigel Report — Dashboard and incident reports

---

## Architecture Decision Records

All architectural decisions are documented in [`/docs/adr`](/docs/adr).

---

## Author

Built by a Solutions Architect in training.
AWS Certified Cloud Practitioner | SAA-C03 in progress.
