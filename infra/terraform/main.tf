########################################
# Foundation
########################################

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

# NOTE: this registry runs in ABAC repository-permissions mode. That preview
# property is not modelled by the azurerm provider, so it is managed outside
# Terraform; Terraform will not touch it.
resource "azurerm_container_registry" "acr" {
  name                = var.registry_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = false
}

########################################
# Identity + ACR role assignments
########################################

# The Container App uses this identity to pull images (no passwords).
resource "azurerm_user_assigned_identity" "app" {
  name                = "curator-identity"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

# Pull role for the app's managed identity (ABAC-native role).
resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "Container Registry Repository Reader"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}

# Push role for the GitHub Actions service principal (ABAC-native role).
resource "azurerm_role_assignment" "acr_push" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "Container Registry Repository Writer"
  principal_id         = var.ci_sp_object_id
}

########################################
# Container Apps
########################################

# Log Analytics workspace backing the Container Apps environment. Named to
# match the workspace Azure auto-created for the existing environment so the
# stack can be imported without a rename.
resource "azurerm_log_analytics_workspace" "aca" {
  name                         = "workspace-rgcuratorzMmj"
  location                     = azurerm_resource_group.main.location
  resource_group_name          = azurerm_resource_group.main.name
  sku                          = "PerGB2018"
  retention_in_days            = 30
  local_authentication_enabled = true
}

resource "azurerm_container_app_environment" "aca" {
  name                       = "curator-env"
  location                   = azurerm_resource_group.main.location
  resource_group_name        = azurerm_resource_group.main.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aca.id

  # Default consumption-only profile (what the CLI created).
  workload_profile {
    name                  = "Consumption"
    workload_profile_type = "Consumption"
    maximum_count         = 0
    minimum_count         = 0
  }
}

resource "azurerm_container_app" "app" {
  name                         = var.app_name
  container_app_environment_id = azurerm_container_app_environment.aca.id
  resource_group_name          = azurerm_resource_group.main.name
  revision_mode                = "Single"
  workload_profile_name        = "Consumption"
  max_inactive_revisions       = 100

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app.id]
  }

  # Pull from ACR via the managed identity (no admin credentials).
  registry {
    server   = azurerm_container_registry.acr.login_server
    identity = azurerm_user_assigned_identity.app.id
  }

  ingress {
    external_enabled = true
    target_port      = 8000
    transport        = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    min_replicas = 0
    max_replicas = 1

    container {
      name   = var.app_name
      image  = "${azurerm_container_registry.acr.login_server}/${var.image_name}:${var.image_tag}"
      cpu    = 0.5
      memory = "1Gi"
    }
  }

  # The CI pipeline rolls the image tag on every deploy. Terraform owns the
  # app's shape, not which image build is live, so ignore image drift.
  # `secret` is ignored too: a stale admin-password secret lingers from before
  # the switch to managed-identity pull; it's unused and not worth managing.
  lifecycle {
    ignore_changes = [
      template[0].container[0].image,
      secret,
    ]
  }
}
