terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# 1. The start line - a Resource Group
resource "azurerm_resource_group" "lab" {
  name     = "rg-storage-lab-maxim"
  location = "West Europe"
}

# 2. Second step - Storage Account
resource "azurerm_storage_account" "main" {
  name                     = "stmaximlab2026"
  resource_group_name      = azurerm_resource_group.lab.name
  location                 = azurerm_resource_group.lab.location
  account_tier             = "Standard"
  account_replication_type = "LRS" # For lab purposes, LRS is cheapest
  
  # Required actions  for Blob Backup
  blob_properties {
    versioning_enabled  = true
    change_feed_enabled = true
  }
}

# 3. The core - Blob Container & File Share
resource "azurerm_storage_container" "blobs" {
  name                  = "nerd-blob"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

resource "azurerm_storage_share" "files" {
  name                 = "cool-share"
  storage_account_name = azurerm_storage_account.main.name
  quota                = 50 # The maximum available GB
}

# 4. Backup Vault (for nerd-bblob)
resource "azurerm_data_protection_backup_vault" "blob_vault" {
  name                = "bv-blob-protection"
  resource_group_name = azurerm_resource_group.lab.name
  location            = azurerm_resource_group.lab.location
  datastore_type      = "VaultStore"
  redundancy          = "LocallyRedundant"
}

# 5. Recovery Services Vault (for cool-file)
resource "azurerm_recovery_services_vault" "file_vault" {
  name                = "rsv-file-protection"
  location            = azurerm_resource_group.lab.location
  resource_group_name = azurerm_resource_group.lab.name
  sku                 = "Standard"
}

# 6. Backup Policy for File Share
resource "azurerm_backup_policy_file_share" "policy" {
  name                = "daily-file-backup"
  resource_group_name = azurerm_resource_group.lab.name
  recovery_vault_name = azurerm_recovery_services_vault.file_vault.name

  backup {
    frequency = "Daily"
    time      = "23:00"
  }

  retention_daily {
    count = 30
  }
}