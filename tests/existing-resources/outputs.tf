########################################################################################################################
# Outputs
########################################################################################################################

output "resource_group_id" {
  description = "The id of the resource group where resources are created."
  value       = module.resource_group.resource_group_id
}

output "resource_group_name" {
  description = "The name of the resource group where resources are created."
  value       = module.resource_group.resource_group_name
}

output "code_engine_project_id" {
  value       = module.code_engine.project_id
  description = "Code Engine Project ID."
}

output "code_engine_job_name" {
  value       = module.code_engine.job["${var.prefix}-job"].name
  description = "Code Engine Job Name"
}

output "prefix" {
  description = "Prefix to append to all resources created by this example."
  value       = var.prefix
}

output "region" {
  value       = var.region
  description = "region."
}
