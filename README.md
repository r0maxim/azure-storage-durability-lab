# Azure Storage & Backup Durability Lab
This project demonstrates the deployment of a hardened Azure Storage environment using **Terraform (Infrastructure as Code)**.

## Architecture Highlights
* **Storage Account (GPv2):** Configured with versioning and change feed enabled.
* **Blob Container:** Protected via **Azure Backup Vault** for operational recovery.
* **File Share:** Managed via **Recovery Services Vault** with a 30-day daily retention policy.
* **Security:** All resources are contained within a dedicated Resource Group for lifecycle management.

## How to Deploy
1. `terraform init`
2. `terraform plan`
3. `terraform apply`
