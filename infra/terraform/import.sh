#!/usr/bin/env bash
# Import the already-deployed resources into Terraform state.
# Safe: import only writes to state, it never changes Azure resources.
set -euo pipefail

SUB="4951b04c-c355-4680-b7da-35b056553963"
RG="/subscriptions/${SUB}/resourceGroups/rg-curator"
ACR="${RG}/providers/Microsoft.ContainerRegistry/registries/curatorregistry"

terraform import azurerm_resource_group.main "${RG}"
terraform import azurerm_container_registry.acr "${ACR}"
terraform import azurerm_user_assigned_identity.app \
  "${RG}/providers/Microsoft.ManagedIdentity/userAssignedIdentities/curator-identity"
terraform import azurerm_role_assignment.acr_pull \
  "${ACR}/providers/Microsoft.Authorization/roleAssignments/bd9bcc81-72b8-46b3-97cb-86fa9dd55ebd"
terraform import azurerm_role_assignment.acr_push \
  "${ACR}/providers/Microsoft.Authorization/roleAssignments/1aa9eb83-8660-4113-bb2a-dda18ff99153"
terraform import azurerm_log_analytics_workspace.aca \
  "${RG}/providers/Microsoft.OperationalInsights/workspaces/workspace-rgcuratorzMmj"
terraform import azurerm_container_app_environment.aca \
  "${RG}/providers/Microsoft.App/managedEnvironments/curator-env"
terraform import azurerm_container_app.app \
  "${RG}/providers/Microsoft.App/containerApps/curator-mcp"

echo "Import complete. Run 'terraform plan' to review drift."
