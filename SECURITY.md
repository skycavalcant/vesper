# Security Policy

## Reporting Security Vulnerabilities

**DO NOT** open public issues for security vulnerabilities.

Instead, email: kaysacsousa@gmail.com

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

We will respond within 48 hours.

---

## Security Principles

Vesper follows these security principles:

### 1. Least Privilege

All IAM roles have minimum permissions required:

```hcl
# ✅ GOOD - Specific resource ARN
Resource = aws_dynamodb_table.events.arn

# ❌ BAD - Wildcard permissions
Resource = "*"
```

### 2. Defense in Depth

Multiple layers of security:
- Input validation at Lambda entry
- IAM policies limiting blast radius
- CloudWatch Logs for audit trail
- DynamoDB encryption at rest

### 3. Secure by Default

- No public endpoints
- Encryption enabled by default
- Secrets in AWS Secrets Manager (not env vars)
- VPC endpoints when needed (future)

---

## Security Checklist

Use this checklist for all PRs:

### IAM & Permissions

- [ ] Policies follow least privilege principle
- [ ] No wildcard (`*`) in Resource ARN
- [ ] No `iam:*` or `s3:*` permissions
- [ ] Service-specific roles (no shared admin roles)
- [ ] Trust policies explicitly define services

### Secrets & Credentials

- [ ] No hardcoded credentials
- [ ] No API keys in code or variables
- [ ] Secrets use AWS Secrets Manager
- [ ] `.env` files in `.gitignore`
- [ ] No PEM/key files committed

### Input Validation

- [ ] All external inputs validated
- [ ] Type checking on event fields
- [ ] Max length limits enforced
- [ ] Special characters sanitized
- [ ] JSON parsing with try/catch

### Logging & Monitoring

- [ ] Sensitive data NOT logged (PII, tokens)
- [ ] CloudWatch Logs retention configured
- [ ] Error messages don't leak internals
- [ ] Audit trail for privileged actions
- [ ] Structured logging (JSON format)

### Dependencies

- [ ] `requirements.txt` pinned versions
- [ ] No known vulnerabilities (`pip-audit`)
- [ ] Minimal dependencies (attack surface)
- [ ] AWS SDK versions up-to-date

### Infrastructure

- [ ] Encryption at rest enabled
- [ ] Encryption in transit (TLS)
- [ ] No public S3 buckets
- [ ] DynamoDB point-in-time recovery (prod)
- [ ] Terraform state encrypted

---

## Security Review Areas

For security-focused coauthors to review:

### Lambda Functions

**Threat Model:**
- Malicious event injection
- Resource exhaustion (timeout, memory)
- Privilege escalation via IAM

**Review:**
```python
# Check for input validation
def lambda_handler(event: Dict[str, Any], context: Any):
    # ✅ Validate structure
    if not isinstance(event.get('detail'), dict):
        raise ValueError("Invalid event structure")
    
    # ✅ Sanitize inputs
    instance_id = event['detail'].get('instance-id', '')
    if not instance_id.startswith('i-'):
        raise ValueError("Invalid instance ID")
```

### IAM Policies

**Review Points:**
- Resource ARNs are specific
- Actions are minimal
- Conditions restrict usage
- Trust policies are explicit

**Example:**
```hcl
# ✅ SECURE
policy = jsonencode({
  Statement = [{
    Effect = "Allow"
    Action = ["dynamodb:PutItem", "dynamodb:GetItem"]
    Resource = aws_dynamodb_table.events.arn
    Condition = {
      StringEquals = {
        "aws:RequestedRegion": "us-east-1"
      }
    }
  }]
})
```

### Terraform State

**Security Concerns:**
- State files contain sensitive data
- Must be encrypted
- Access should be restricted

**Configuration:**
```hcl
terraform {
  backend "s3" {
    bucket         = "vesper-tfstate-encrypted"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true  # ✅ Required
    dynamodb_table = "terraform-locks"
    kms_key_id     = "arn:aws:kms:..."  # ✅ CMK
  }
}
```

---

## Common Vulnerabilities to Prevent

### 1. Command Injection

```python
# ❌ VULNERABLE
os.system(f"aws s3 cp {user_input} /tmp/")

# ✅ SAFE
subprocess.run(['aws', 's3', 'cp', user_input, '/tmp/'], check=True)
```

### 2. SQL/NoSQL Injection

```python
# ❌ VULNERABLE (if using SQL)
query = f"SELECT * FROM events WHERE id = '{event_id}'"

# ✅ SAFE (DynamoDB uses parameterized queries)
table.get_item(Key={'event_id': event_id})
```

### 3. Information Disclosure

```python
# ❌ VULNERABLE
except Exception as e:
    return {'error': str(e)}  # Leaks stack trace

# ✅ SAFE
except Exception as e:
    print(f"Error: {e}")  # Log internally
    return {'error': 'Internal error'}  # Generic message
```

### 4. Resource Exhaustion

```python
# ❌ VULNERABLE
data = json.loads(event['body'])  # Unbounded size

# ✅ SAFE
MAX_SIZE = 256 * 1024  # 256 KB
if len(event.get('body', '')) > MAX_SIZE:
    raise ValueError("Payload too large")
```

---

## Incident Response

If a security issue is discovered in production:

1. **Contain:** Disable affected Lambda/resource
2. **Assess:** Determine scope and impact
3. **Remediate:** Deploy fix to dev → test → prod
4. **Document:** Post-mortem in `/docs/incidents/`
5. **Notify:** Inform stakeholders if data exposed

---

## Security Tools

### Recommended

- **Terraform:** TFSec, Checkov
- **Python:** Bandit, pip-audit
- **Secrets:** git-secrets, truffleHog
- **SAST:** Semgrep

### Usage

```bash
# Scan Terraform for security issues
tfsec infra/

# Check Python for vulnerabilities
bandit -r modules/

# Audit Python dependencies
pip-audit

# Scan for secrets
git-secrets --scan
```

---

## Compliance

Vesper is designed for:
- ✅ AWS Well-Architected Framework (Security Pillar)
- ✅ Principle of Least Privilege (PoLP)
- ✅ Defense in Depth
- ⚠️ SOC 2 / ISO 27001 (future consideration)

---

## Questions?

Security concerns or questions? Contact the security coauthor or open a **private** security issue.

**Remember:** Security is everyone's responsibility, but specialized review prevents oversights.
