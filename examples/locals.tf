locals {
  timestamp           = timestamp()
  timestamp_sanitized = formatdate("DD MMM YYYY hh:mm ZZZ", local.timestamp)
  timestamp_tag = {
    creation_timestamp = local.timestamp_sanitized
  }
  resource_suffix = "qoh-prod-cus"
  resource_tags = {
    "environment" = "prod"
    "region"      = "centralus"
    "cost_center" = "6001"
    "reason"      = "JIRA-12345"
    "created_by"  = "veera-bhadra"
    "project"     = "questopshub"
    "source"      = "terraform"
    "owner"       = "veera-bhadra"
    "team"        = "infrateam"
  }
}