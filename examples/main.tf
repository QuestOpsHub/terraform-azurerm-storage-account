#---------------
# Random String
#---------------
module "random_string" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-random-string.git?ref=v1.0.0"

  length  = 4
  lower   = true
  numeric = true
  special = false
  upper   = false
}

#----------------
# Resource Group
#----------------
module "resource_group" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-resource-group.git?ref=v1.0.0"

  name     = "rg-${local.resource_suffix}-${module.random_string.result}"
  location = "centralus"
  tags     = merge(local.resource_tags, local.timestamp_tag)
}

#------------------------
# User Assigned Identity
#------------------------
module "user_assigned_identity" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-user-assigned-identity.git?ref=v1.0.0"

  name                = "id-${local.resource_suffix}-${module.random_string.result}"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  tags                = merge(local.resource_tags, local.timestamp_tag)
}

#-----------------
# Storage Account
#-----------------
module "storage_account" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-storage-account.git?ref=v1.0.0"

  name                     = lower(replace("st-${local.resource_suffix}-${module.random_string.result}", "/[[:^alnum:]]/", ""))
  resource_group_name      = module.resource_group.name
  location                 = module.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = false
  nfsv3_enabled            = true
  identity = {
    type         = "UserAssigned"
    identity_ids = [module.user_assigned_identity.id]
  }
  blob_properties = {
    cors_rule = {
      allowed_headers    = ["*"]
      allowed_methods    = ["GET"]
      allowed_origins    = ["https://*.lightmetrics.co", "https://*.detroitconnect.com", "http://localhost:4300"]
      exposed_headers    = ["x-ms-meta-*"]
      max_age_in_seconds = "200"
    }
    versioning_enabled = true
  }
  queue_properties = {
    cors_rule = {
      allowed_headers    = ["*"]
      allowed_methods    = ["GET", "OPTIONS"]
      allowed_origins    = ["https://myhost.com"]
      exposed_headers    = ["*"]
      max_age_in_seconds = "200"
    }
  }
  share_properties = {
    cors_rule = {
      allowed_headers    = ["*"]
      allowed_methods    = ["GET"]
      allowed_origins    = ["https://myhost.com"]
      exposed_headers    = ["x-ms-meta-*"]
      max_age_in_seconds = "200"
    }
  }
  network_rules = {
    default_action      = "Allow" # @todo set back to Deny
    bypass              = ["AzureServices", "Metrics"]
    ip_rules            = []
    subnet_details      = {}
    private_link_access = {}
  }
  tags = merge(local.resource_tags, local.timestamp_tag)
}