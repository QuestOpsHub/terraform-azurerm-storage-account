#-----------------
# Storage Account
#-----------------
output "name" {
  description = "The Storage Account Name."
  value       = azurerm_storage_account.storage_account.name
}

output "id" {
  description = "The Storage Account ID."
  value       = azurerm_storage_account.storage_account.id
}

output "primary_location" {
  description = "The primary location of the Storage Account."
  value       = azurerm_storage_account.storage_account.primary_location
}

output "secondary_location" {
  description = "The secondary location of the Storage Account."
  value       = azurerm_storage_account.storage_account.secondary_location
}

output "primary_blob_endpoint" {
  description = "The primary endpoint for Blob storage."
  value       = azurerm_storage_account.storage_account.primary_blob_endpoint
}

output "primary_blob_host" {
  description = "The primary Blob host URL."
  value       = azurerm_storage_account.storage_account.primary_blob_host
}

output "secondary_blob_endpoint" {
  description = "The secondary endpoint for Blob storage."
  value       = azurerm_storage_account.storage_account.secondary_blob_endpoint
}

output "secondary_blob_host" {
  description = "The secondary Blob host URL."
  value       = azurerm_storage_account.storage_account.secondary_blob_host
}

output "primary_queue_endpoint" {
  description = "The primary endpoint for Queue storage."
  value       = azurerm_storage_account.storage_account.primary_queue_endpoint
}

output "secondary_queue_endpoint" {
  description = "The secondary endpoint for Queue storage."
  value       = azurerm_storage_account.storage_account.secondary_queue_endpoint
}

output "secondary_queue_host" {
  description = "The secondary Queue host URL."
  value       = azurerm_storage_account.storage_account.secondary_queue_host
}

output "primary_table_endpoint" {
  description = "The primary endpoint for Table storage."
  value       = azurerm_storage_account.storage_account.primary_table_endpoint
}

output "primary_table_host" {
  description = "The primary Table host URL."
  value       = azurerm_storage_account.storage_account.primary_table_host
}

output "secondary_table_endpoint" {
  description = "The secondary endpoint for Table storage."
  value       = azurerm_storage_account.storage_account.secondary_table_endpoint
}

output "secondary_table_host" {
  description = "The secondary Table host URL."
  value       = azurerm_storage_account.storage_account.secondary_table_host
}

output "primary_file_endpoint" {
  description = "The primary endpoint for File storage."
  value       = azurerm_storage_account.storage_account.primary_file_endpoint
}

output "primary_file_host" {
  description = "The primary File host URL."
  value       = azurerm_storage_account.storage_account.primary_file_host
}

output "secondary_file_endpoint" {
  description = "The secondary endpoint for File storage."
  value       = azurerm_storage_account.storage_account.secondary_file_endpoint
}

output "secondary_file_host" {
  description = "The secondary File host URL."
  value       = azurerm_storage_account.storage_account.secondary_file_host
}

output "primary_dfs_endpoint" {
  description = "The primary endpoint for Data Lake storage (DFS)."
  value       = azurerm_storage_account.storage_account.primary_dfs_endpoint
}

output "primary_dfs_host" {
  description = "The primary DFS host URL."
  value       = azurerm_storage_account.storage_account.primary_dfs_host
}

output "secondary_dfs_endpoint" {
  description = "The secondary endpoint for Data Lake storage (DFS)."
  value       = azurerm_storage_account.storage_account.secondary_dfs_endpoint
}

output "secondary_dfs_host" {
  description = "The secondary DFS host URL."
  value       = azurerm_storage_account.storage_account.secondary_dfs_host
}

output "primary_web_endpoint" {
  description = "The primary endpoint for web storage."
  value       = azurerm_storage_account.storage_account.primary_web_endpoint
}

output "primary_web_host" {
  description = "The primary web host URL."
  value       = azurerm_storage_account.storage_account.primary_web_host
}

output "secondary_web_endpoint" {
  description = "The secondary endpoint for web storage."
  value       = azurerm_storage_account.storage_account.secondary_web_endpoint
}

output "secondary_web_host" {
  description = "The secondary web host URL."
  value       = azurerm_storage_account.storage_account.secondary_web_host
}

output "primary_access_key" {
  description = "The primary access key for the Storage Account."
  value       = azurerm_storage_account.storage_account.primary_access_key
}

output "secondary_access_key" {
  description = "The secondary access key for the Storage Account."
  value       = azurerm_storage_account.storage_account.secondary_access_key
}

output "primary_connection_string" {
  description = "The primary connection string for the Storage Account."
  value       = azurerm_storage_account.storage_account.primary_connection_string
}

output "secondary_connection_string" {
  description = "The secondary connection string for the Storage Account."
  value       = azurerm_storage_account.storage_account.secondary_connection_string
}

output "primary_blob_connection_string" {
  description = "The primary Blob connection string for the Storage Account."
  value       = azurerm_storage_account.storage_account.primary_blob_connection_string
}

output "secondary_blob_connection_string" {
  description = "The secondary Blob connection string for the Storage Account."
  value       = azurerm_storage_account.storage_account.secondary_blob_connection_string
}

output "identity" {
  description = "The managed identity information for the Storage Account."
  value       = azurerm_storage_account.storage_account.identity
}