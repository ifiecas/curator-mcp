# Curator MCP — Infrastructure (Terraform)

Declarative definition of the whole stack: resource group, ACR (admin
disabled), a user-assigned managed identity with ABAC pull/push role
assignments, a Container Apps environment (+ Log Analytics workspace), and the
Container App itself (HTTPS ingress, scale-to-zero, identity-based ACR pull).

Terraform owns the **shape** of the infrastructure. The GitHub Actions pipeline
owns **which image build is live** — the container image tag is under
`ignore_changes`, so `terraform apply` never fights a deploy.

## Prerequisites

- Terraform >= 1.5, Azure CLI, and `az login` as a user with Owner (needed for
  the role assignments).

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Adopting the existing (already-deployed) stack

The resources were first created with `az` commands. Import them into Terraform
state so `terraform plan` reconciles against reality instead of trying to
recreate them:

```bash
./import.sh
terraform plan   # review drift, then apply only if you accept it
```

`terraform import` and `terraform plan` never modify infrastructure — only
`apply` does. Review the plan carefully before applying against live resources.
