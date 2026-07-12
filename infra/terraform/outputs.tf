output "mcp_endpoint" {
  description = "Public HTTPS MCP endpoint."
  value       = "https://${azurerm_container_app.app.ingress[0].fqdn}/mcp"
}

output "registry_login_server" {
  description = "ACR login server (carries a unique DNS suffix)."
  value       = azurerm_container_registry.acr.login_server
}

output "identity_client_id" {
  description = "Client ID of the app's user-assigned managed identity."
  value       = azurerm_user_assigned_identity.app.client_id
}
