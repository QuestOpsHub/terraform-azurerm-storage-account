#-----------------
# Storage Account
#-----------------
data "azurerm_client_config" "current" {}

resource "azurerm_storage_account" "storage_account" {
  name                             = var.name
  resource_group_name              = var.resource_group_name
  location                         = var.location
  account_kind                     = try(var.account_kind, "StorageV2")
  account_tier                     = var.account_tier
  account_replication_type         = var.account_replication_type
  cross_tenant_replication_enabled = try(var.cross_tenant_replication_enabled, true)
  access_tier                      = try(var.access_tier, "Hot")
  edge_zone                        = try(var.edge_zone, null)
  https_traffic_only_enabled       = try(var.https_traffic_only_enabled, true)
  min_tls_version                  = try(var.min_tls_version, "TLS1_2")
  allow_nested_items_to_be_public  = try(var.allow_nested_items_to_be_public, true)
  shared_access_key_enabled        = try(var.shared_access_key_enabled, true)
  public_network_access_enabled    = try(var.public_network_access_enabled, true)
  default_to_oauth_authentication  = try(var.default_to_oauth_authentication, false)
  is_hns_enabled = (
    var.account_tier == "Standard" ||
    (var.account_tier == "Premium" && var.account_kind == "BlockBlobStorage")
  ) ? var.is_hns_enabled : false
  nfsv3_enabled = (
    (var.account_tier == "Standard" && var.account_kind == "StorageV2" && var.is_hns_enabled == true && contains(["LRS", "RAGRS"], var.account_replication_type)) ||
    (var.account_tier == "Premium" && var.account_kind == "BlockBlobStorage" && var.is_hns_enabled == true && contains(["LRS", "RAGRS"], var.account_replication_type))
  ) ? var.nfsv3_enabled : false

  dynamic "custom_domain" {
    for_each = try(var.custom_domain, {}) != {} ? [var.custom_domain] : []
    content {
      name          = custom_domain.value.name
      use_subdomain = lookup(custom_domain.value, "use_subdomain", null)
    }
  }

  dynamic "customer_managed_key" {
    for_each = (
      (var.account_kind == "StorageV2" || var.account_tier == "Premium") &&
      var.identity.type == "UserAssigned" &&
      try(var.customer_managed_key, {}) != {}
    ) ? [var.customer_managed_key] : []
    content {
      key_vault_key_id          = lookup(customer_managed_key.value, "managed_hsm_key_id", null) == null ? lookup(customer_managed_key.value, "key_vault_key_id", null) : null
      managed_hsm_key_id        = lookup(customer_managed_key.value, "key_vault_key_id", null) == null ? lookup(customer_managed_key.value, "managed_hsm_key_id", null) : null
      user_assigned_identity_id = customer_managed_key.value.user_assigned_identity_id
    }
  }

  dynamic "identity" {
    for_each = try(var.identity.type, null) != null ? [var.identity.type] : []
    content {
      type         = var.identity.type
      identity_ids = var.identity.type == "UserAssigned" || var.identity.type == "SystemAssigned, UserAssigned" ? var.identity.identity_ids : null
    }
  }

  # blob_properties block begin
  dynamic "blob_properties" {
    for_each = try(var.blob_properties, {}) != {} ? [var.blob_properties] : []
    content {
      dynamic "cors_rule" {
        for_each = lookup(blob_properties.value, "cors_rule", {}) != {} ? [blob_properties.value.cors_rule] : []
        content {
          allowed_headers    = cors_rule.value.allowed_headers
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_origins    = cors_rule.value.allowed_origins
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }
      dynamic "delete_retention_policy" {
        for_each = lookup(blob_properties.value, "delete_retention_policy", {}) != {} ? [blob_properties.value.delete_retention_policy] : []
        content {
          days = lookup(delete_retention_policy.value, "days", "7")
          permanent_delete_enabled = (
          lookup(blob_properties.value, "restore_policy", {}) != {}) ? false : lookup(delete_retention_policy.value, "permanent_delete_enabled", false)
        }
      }
      dynamic "restore_policy" {
        for_each = (
          lookup(blob_properties.value, "restore_policy", {}) != {} &&
          var.account_kind != "Storage" &&
          var.dns_endpoint_type != "AzureDnsZone" &&
          lookup(blob_properties.value, "delete_retention_policy", {}) != {} &&
          lookup(blob_properties.value, "versioning_enabled", false) == true &&
          lookup(blob_properties.value, "change_feed_enabled", false) == true
        ) ? [blob_properties.value.restore_policy] : []
        content {
          days = restore_policy.value.days
        }
      }
      versioning_enabled            = var.account_kind != "Storage" ? lookup(blob_properties.value, "versioning_enabled", false) : false
      change_feed_enabled           = var.account_kind != "Storage" ? lookup(blob_properties.value, "change_feed_enabled", false) : false
      change_feed_retention_in_days = var.account_kind != "Storage" ? lookup(blob_properties.value, "change_feed_retention_in_days", null) : null
      default_service_version       = lookup(blob_properties.value, "default_service_version", null)
      last_access_time_enabled      = var.account_kind != "Storage" ? lookup(blob_properties.value, "last_access_time_enabled", false) : false
      dynamic "container_delete_retention_policy" {
        for_each = lookup(blob_properties.value, "container_delete_retention_policy", {}) != {} ? [blob_properties.value.container_delete_retention_policy] : []
        content {
          days = lookup(container_delete_retention_policy.value, "days", "7")
        }
      }
    }
  }
  # blob_properties block end

  # queue_properties block begin
  dynamic "queue_properties" {
    for_each = (
      try(var.queue_properties, {}) != {} &&
      var.account_tier == "Standard" &&
      (var.account_kind == "Storage" || var.account_kind == "StorageV2")
    ) ? [var.queue_properties] : []
    content {
      dynamic "cors_rule" {
        for_each = lookup(queue_properties.value, "cors_rule", {}) != {} ? [queue_properties.value.cors_rule] : []
        content {
          allowed_headers    = cors_rule.value.allowed_headers
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_origins    = cors_rule.value.allowed_origins
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }
      dynamic "logging" {
        for_each = lookup(queue_properties.value, "logging", {}) != {} ? [queue_properties.value.logging] : []
        content {
          delete                = logging.value.delete
          read                  = logging.value.read
          version               = logging.value.version
          write                 = logging.value.write
          retention_policy_days = lookup(logging.value, "retention_policy_days", null)
        }
      }
      dynamic "minute_metrics" {
        for_each = lookup(queue_properties.value, "minute_metrics", {}) != {} ? [queue_properties.value.minute_metrics] : []
        content {
          enabled               = minute_metrics.value.enabled
          version               = minute_metrics.value.version
          include_apis          = lookup(minute_metrics.value, "include_apis", null)
          retention_policy_days = lookup(minute_metrics.value, "retention_policy_days", null)
        }
      }
      dynamic "hour_metrics" {
        for_each = lookup(queue_properties.value, "hour_metrics", {}) != {} ? [queue_properties.value.hour_metrics] : []
        content {
          enabled               = hour_metrics.value.enabled
          version               = hour_metrics.value.version
          include_apis          = lookup(hour_metrics.value, "include_apis", null)
          retention_policy_days = lookup(hour_metrics.value, "retention_policy_days", null)
        }
      }
    }
  }
  # queue_properties block end

  # static_website block begin
  dynamic "static_website" {
    for_each = (try(var.static_website, {}) != {} && (var.account_kind == "StorageV2" || var.account_kind == "BlockBlobStorage")) ? [var.static_website] : []
    content {
      index_document     = lookup(static_website.value, "index_document", null)
      error_404_document = lookup(static_website.value, "error_404_document", null)
    }
  }
  # static_website block end

  # share_properties block begin
  dynamic "share_properties" {
    for_each = (
      try(var.share_properties, {}) != {} &&
      (
        (var.account_tier == "Standard" && (var.account_kind == "Storage" || var.account_kind == "StorageV2")) ||
        (var.account_tier == "Premium" && var.account_kind == "FileStorage")
      )
    ) ? [var.share_properties] : []
    content {
      dynamic "cors_rule" {
        for_each = lookup(share_properties.value, "cors_rule", {}) != {} ? [share_properties.value.cors_rule] : []
        content {
          allowed_headers    = cors_rule.value.allowed_headers
          allowed_methods    = cors_rule.value.allowed_methods
          allowed_origins    = cors_rule.value.allowed_origins
          exposed_headers    = cors_rule.value.exposed_headers
          max_age_in_seconds = cors_rule.value.max_age_in_seconds
        }
      }
      dynamic "retention_policy" {
        for_each = lookup(share_properties.value, "retention_policy", {}) != {} ? [share_properties.value.retention_policy] : []
        content {
          days = lookup(retention_policy.value, "days", "7")
        }
      }
      dynamic "smb" {
        for_each = lookup(share_properties.value, "smb", {}) != {} ? [share_properties.value.smb] : []
        content {
          versions                        = lookup(smb.value, "versions", null)
          authentication_types            = lookup(smb.value, "authentication_types", null)
          kerberos_ticket_encryption_type = lookup(smb.value, "kerberos_ticket_encryption_type", null)
          channel_encryption_type         = lookup(smb.value, "channel_encryption_type", null)
          multichannel_enabled            = lookup(smb.value, "multichannel_enabled", null)
        }
      }
    }
  }
  # share_properties block end

  # network_rules block begin
  dynamic "network_rules" {
    for_each = (
      try(var.network_rules, {}) != {} &&
      (
        (lookup(var.network_rules, "ip_rules", null) != null || length(keys(lookup(var.network_rules, "subnet_details", {}))) > 0) &&
        lookup(var.network_rules, "default_action", "Deny") == "Deny"
      )
    ) ? [var.network_rules] : []
    content {
      default_action             = network_rules.value.default_action
      bypass                     = lookup(network_rules.value, "bypass", null)
      ip_rules                   = lookup(network_rules.value, "ip_rules", null)
      virtual_network_subnet_ids = flatten([for ids, value in try(network_rules.value.subnet_details, {}) : "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${value.vnet_rg_name}/providers/Microsoft.Network/virtualNetworks/${value.vnet_name}/subnets/${value.subnet_name}"])
      dynamic "private_link_access" {
        for_each = length(keys(lookup(network_rules.value, "private_link_access", {}))) > 0 ? lookup(network_rules.value, "private_link_access", {}) : {}
        content {
          endpoint_resource_id = private_link_access.value.endpoint_resource_id
          endpoint_tenant_id   = lookup(private_link_access.value, "endpoint_tenant_id", null)
        }
      }
    }
  }
  # network_rules block end

  large_file_share_enabled = try(var.large_file_share_enabled, false)
  local_user_enabled       = try(var.local_user_enabled, true)

  # azure_files_authentication block begin
  dynamic "azure_files_authentication" {
    for_each = try(var.azure_files_authentication, {}) != {} ? [var.azure_files_authentication] : []
    content {
      directory_type = azure_files_authentication.value.directory_type
      dynamic "active_directory" {
        for_each = azure_files_authentication.value.directory_type == "AD" ? [azure_files_authentication.value.active_directory] : []
        content {
          domain_name         = active_directory.value.domain_name
          domain_guid         = active_directory.value.domain_guid
          domain_sid          = azure_files_authentication.value.directory_type == "AD" ? active_directory.value.domain_sid : null
          storage_sid         = azure_files_authentication.value.directory_type == "AD" ? active_directory.value.storage_sid : null
          forest_name         = azure_files_authentication.value.directory_type == "AD" ? active_directory.value.forest_name : null
          netbios_domain_name = azure_files_authentication.value.directory_type == "AD" ? active_directory.value.netbios_domain_name : null
        }
      }
      default_share_level_permission = lookup(azure_files_authentication.value, "default_share_level_permission", null)
    }
  }
  # azure_files_authentication block end

  dynamic "routing" {
    for_each = try(var.routing, {}) != {} ? [var.routing] : []
    content {
      publish_internet_endpoints  = lookup(routing.value, "publish_internet_endpoints", false)
      publish_microsoft_endpoints = lookup(routing.value, "publish_microsoft_endpoints", false)
      choice                      = lookup(routing.value, "choice", "MicrosoftRouting")
    }
  }

  queue_encryption_key_type         = var.account_kind == "StorageV2" ? try(var.queue_encryption_key_type, "Service") : null
  table_encryption_key_type         = var.account_kind == "StorageV2" ? var.table_encryption_key_type : null
  infrastructure_encryption_enabled = (var.account_kind == "StorageV2") || (var.account_tier == "Premium" && (var.account_kind == "BlockBlobStorage" || var.account_kind == "FileStorage")) ? try(var.infrastructure_encryption_enabled, true) : false

  dynamic "immutability_policy" {
    for_each = try(var.immutability_policy, {}) != {} ? [var.immutability_policy] : []
    content {
      allow_protected_append_writes = immutability_policy.value.allow_protected_append_writes
      state                         = immutability_policy.value.state
      period_since_creation_in_days = immutability_policy.value.period_since_creation_in_days
    }
  }

  dynamic "sas_policy" {
    for_each = try(var.sas_policy, {}) != {} ? [var.sas_policy] : []
    content {
      expiration_period = sas_policy.value.expiration_period
      expiration_action = lookup(sas_policy.value, "expiration_action", "Log")
    }
  }

  allowed_copy_scope = try(var.allowed_copy_scope, null)
  sftp_enabled       = var.is_hns_enabled == true ? var.sftp_enabled : false
  dns_endpoint_type  = try(var.dns_endpoint_type, "Standard")

  tags = var.tags
  lifecycle {
    ignore_changes = [
      tags["creation_timestamp"],
    ]
  }
}