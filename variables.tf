#-----------------
# Storage Account
#-----------------
variable "name" {
  description = "(Required) Specifies the name of the storage account. Only lowercase Alphanumeric characters allowed. Changing this forces a new resource to be created. This must be unique across the entire Azure service, not just within the resource group."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the storage account. Changing this forces a new resource to be created."
  type        = string
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  type        = string
}

variable "account_kind" {
  description = "(Optional) Defines the Kind of account. Valid options are BlobStorage, BlockBlobStorage, FileStorage, Storage and StorageV2. Defaults to StorageV2."
  type        = string
  default     = "StorageV2"
}

variable "account_tier" {
  description = "(Required) Defines the Tier to use for this storage account. Valid options are Standard and Premium. For BlockBlobStorage and FileStorage accounts only Premium is valid. Changing this forces a new resource to be created."
  type        = string
}

variable "edge_zone" {
  description = "(Optional) Specifies the Edge Zone within the Azure Region where this Storage Account should exist. Changing this forces a new Storage Account to be created."
  type        = string
  default     = null
}

variable "account_replication_type" {
  description = "(Required) Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS. Changing this forces a new resource to be created when types LRS, GRS and RAGRS are changed to ZRS, GZRS or RAGZRS and vice versa."
  type        = string
}

variable "cross_tenant_replication_enabled" {
  description = "(Optional) Should cross Tenant replication be enabled? Defaults to true."
  type        = bool
  default     = true
}

variable "access_tier" {
  description = "(Optional) Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool, defaults to Hot."
  type        = string
  default     = "Hot"
}

variable "https_traffic_only_enabled" {
  description = "(Optional) Boolean flag which forces HTTPS if enabled, see here for more information. Defaults to true."
  type        = bool
  default     = true
}

variable "min_tls_version" {
  description = "(Optional) The minimum supported TLS version for the storage account. Possible values are TLS1_0, TLS1_1, and TLS1_2. Defaults to TLS1_2 for new storage accounts."
  type        = string
  default     = "TLS1_2"
}

variable "allow_nested_items_to_be_public" {
  description = "(Optional) Allow or disallow nested items within this Account to opt into being public. Defaults to true."
  type        = bool
  default     = true
}

variable "shared_access_key_enabled" {
  description = "(Optional) Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key. If false, then all requests, including shared access signatures, must be authorized with Azure Active Directory (Azure AD). Defaults to true."
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "(Optional) Whether the public network access is enabled? Defaults to true."
  type        = bool
  default     = true
}

variable "default_to_oauth_authentication" {
  description = "(Optional) Default to Azure Active Directory authorization in the Azure portal when accessing the Storage Account. The default value is false"
  type        = bool
  default     = false
}

variable "is_hns_enabled" {
  description = "(Optional) Is Hierarchical Namespace enabled? This can be used with Azure Data Lake Storage Gen 2 (see here for more information). Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "nfsv3_enabled" {
  description = "(Optional) Is NFSv3 protocol enabled? Changing this forces a new resource to be created. Defaults to false."
  type        = bool
  default     = false
}

variable "custom_domain" {
  description = "(Optional) A custom_domain block."
  type        = any
  default     = {}
}

variable "customer_managed_key" {
  description = "(Optional) A customer_managed_key block."
  type        = any
  default     = {}
}

variable "identity" {
  description = "(Optional) An identity block"
  type        = any
  default     = {}
}

variable "blob_properties" {
  description = "(Optional) A blob_properties block."
  type        = any
  default     = {}
}

variable "queue_properties" {
  description = "(Optional) A queue_properties block."
  type        = any
  default     = {}
}

variable "static_website" {
  description = "(Optional) A static_website block."
  type        = any
  default     = {}
}

variable "share_properties" {
  description = "(Optional) A share_properties block."
  type        = any
  default     = {}
}

variable "network_rules" {
  description = "(Optional) A network_rules block."
  type        = any
  default     = {}
}

variable "large_file_share_enabled" {
  description = "(Optional) Are Large File Shares Enabled? Defaults to false."
  type        = bool
  default     = false
}

variable "local_user_enabled" {
  description = "(Optional) Is Local User Enabled? Defaults to true."
  type        = bool
  default     = true
}

variable "azure_files_authentication" {
  description = "(Optional) A azure_files_authentication block."
  type        = any
  default     = {}
}

variable "routing" {
  description = "(Optional) A routing block."
  type        = any
  default     = {}
}

variable "queue_encryption_key_type" {
  description = "(Optional) The encryption type of the queue service. Possible values are Service and Account. Changing this forces a new resource to be created. Default value is Service."
  type        = string
  default     = "Service"
}

variable "table_encryption_key_type" {
  description = "(Optional) The encryption type of the table service. Possible values are Service and Account. Changing this forces a new resource to be created. Default value is Service."
  type        = string
  default     = null
}

variable "infrastructure_encryption_enabled" {
  description = "(Optional) Is infrastructure encryption enabled? Changing this forces a new resource to be created. Defaults to false."
  type        = bool
  default     = false
}

variable "immutability_policy" {
  description = "(Optional) A immutability_policy block."
  type        = any
  default     = {}
}

variable "sas_policy" {
  description = "(Optional) A sas_policy block."
  type        = any
  default     = {}
}

variable "allowed_copy_scope" {
  description = "(Optional) Restrict copy to and from Storage Accounts within an AAD tenant or with Private Links to the same VNet. Possible values are AAD and PrivateLink."
  type        = string
  default     = null
}

variable "sftp_enabled" {
  description = "(Optional) Boolean, enable SFTP for the storage account"
  type        = bool
  default     = false
}

variable "dns_endpoint_type" {
  description = "(Optional) Specifies which DNS endpoint type to use. Possible values are Standard and AzureDnsZone. Defaults to Standard. Changing this forces a new resource to be created."
  type        = string
  default     = "Standard"
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resource."
  type        = map(any)
  default     = {}
}