variable "subscription_id" {
  description = "Azure subscription ID to deploy into."
  type        = string
  default     = "4951b04c-c355-4680-b7da-35b056553963"
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "australiaeast"
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
  default     = "rg-curator"
}

variable "registry_name" {
  description = "Azure Container Registry name (globally unique)."
  type        = string
  default     = "curatorregistry"
}

variable "app_name" {
  description = "Container App name."
  type        = string
  default     = "curator-mcp"
}

variable "image_name" {
  description = "Container image repository name in the registry."
  type        = string
  default     = "curator-mcp"
}

variable "image_tag" {
  description = "Image tag used only at first create; the CI pipeline manages the live tag thereafter (see ignore_changes on the container image)."
  type        = string
  default     = "latest"
}

variable "ci_sp_object_id" {
  description = "Object ID of the GitHub Actions service principal (github-curator-sp) that pushes images."
  type        = string
  default     = "ed910d02-e6db-4f47-8597-6ef56588b79b"
}
