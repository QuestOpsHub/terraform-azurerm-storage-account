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
# Virtual Network
#-----------------
module "virtual_network" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-virtual-network.git?ref=v1.0.0"

  name                = "vnet-${local.resource_suffix}-${module.random_string.result}"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  address_space       = ["101.0.0.0/16", "102.0.0.0/16"]
  subnets = {
    aks = {
      name             = "aks"
      address_prefixes = ["101.0.0.0/20"]
    },
    # aks and aks-nodepool subnets must not be in same vnet range.
    aks-nodepool = {
      name             = "aks-nodepool"
      address_prefixes = ["102.0.0.0/20"]
    },
  }
  tags = merge(local.resource_tags, local.timestamp_tag)
}

#--------------------------
# Azure Kubernetes Cluster
#--------------------------
module "kubernetes_cluster" {
  source = "git::https://github.com/QuestOpsHub/terraform-azurerm-kubernetes-cluster.git?ref=v1.0.0"

  name                = "aks-${local.resource_suffix}-${module.random_string.result}"
  location            = module.resource_group.location
  resource_group_name = module.resource_group.name
  default_node_pool = {
    name                 = "system"
    vm_size              = "Standard_DS2_v2"
    auto_scaling_enabled = true
    max_pods             = 50
    node_labels = {
      "nodepool-type" = "system"
      "environment"   = "dev"
      "nodepoolos"    = "linux"
      "app"           = "system-apps"
    }
    only_critical_addons_enabled = true
    os_disk_size_gb              = 30
    temporary_name_for_rotation  = "defaulttemp"
    type                         = "VirtualMachineScaleSets"
    tags = {
      "nodepool-type" = "system"
      "environment"   = "dev"
      "nodepoolos"    = "linux"
      "app"           = "system-apps"
    }
    upgrade_settings = {
      max_surge = "50%"
    }
    vnet_subnet_id = module.virtual_network.subnets["aks"].id
    # zones     = [1, 2, 3]
    zones     = [3] # The VM size of Standard_DS2_v2 is only allowed  in zones [3] in your subscription in location 'centralus'.
    max_count = 3
    min_count = 1
  }
  azure_active_directory_role_based_access_control = {
    admin_group_object_ids = ["XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX"]
    azure_rbac_enabled     = false
  }
  azure_policy_enabled = true
  identity = {
    type         = "UserAssigned"
    identity_ids = [module.user_assigned_identity.id]
  }
  /*
  linux_profile = {
    adminuser  = "ADMINUSER"
    public_key = "public_key"
  }
  */
  network_profile = {
    network_plugin      = "azure"
    network_mode        = null
    network_policy      = "azure"
    dns_service_ip      = null
    network_data_plane  = "azure"
    network_plugin_mode = null
    outbound_type       = "loadBalancer"
    service_cidr        = null
    ip_versions         = ["IPv4"]
    load_balancer_sku   = "standard"
    pod_cidrs           = []
  }
  workload_identity_enabled = false # Azure AD Workload Identity requires OIDC issuer. Please see https://aka.ms/aks/wi for details.
  sku_tier                  = "Standard"
  /*
  windows_profile = {
    admin_username = "ADMINUSER"
    admin_password = "ADMINPASSWORD"
  }
  */
  kubernetes_cluster_node_pool = {
    infrateam = {
      vm_size             = "Standard_DS2_v2"
      enable_auto_scaling = true
      mode                = "user"
      min_count           = "0"
      max_count           = "50"
      node_taints         = ["app=infrateam:NoSchedule"]
      node_labels         = { "app" = "infrateam" }
      vnet_subnet_id      = module.virtual_network.subnets["aks-nodepool"].id
    },
  }
  tags = merge(local.resource_tags, local.timestamp_tag)
}