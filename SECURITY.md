# Security Policy

This repository follows industry best practices for secure Infrastructure-as-Code
and CI/CD automation.

##  Secrets Management

- No secrets, credentials, tokens, or keys are stored in this repository.
- All sensitive values (e.g. GitHub PATs, Azure credentials) are stored as **Azure DevOps secret variables** or **Variable Groups**.
- Secrets are never logged, echoed, or committed to version control.

##  Authentication & Authorization

- Azure deployments use **Azure DevOps Service Connections** with least-privilege RBAC.
- GitHub access is performed via a **read-only mirror** using a scoped Personal Access Token (PAT).
- GitHub is not a source of truth and does not accept direct changes.

##  Source of Truth

- **Azure Repos** is the authoritative source of truth for all repositories.
- **GitHub repositories are mirrors (read-only)** for visibility and portfolio purposes.
- All changes must go through Azure DevOps Pull Requests.

##  CI/CD Safety Controls

- Pipelines validate templates using `az bicep build`.
- Deployments use **ARM What-If** for safe preview before any change.
- No automatic production deployments are executed without manual approval.

##  Public Exposure

- This repository intentionally exposes only non-sensitive configuration values
  (environment names, locations, resource group names).
- These values do not grant access to any Azure or GitHub resources.

##  Reporting Security Issues

If you discover a potential security issue, please report it privately.
No sensitive information should be disclosed via public issues.

---

Maintained with security-by-design and least-privilege principles.
