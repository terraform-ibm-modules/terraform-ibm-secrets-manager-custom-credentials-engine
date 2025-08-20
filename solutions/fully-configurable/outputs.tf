output "custom_config_engine_id" {
  description = "The unique identifier of the engine created."
  value       = module.custom_credential_engine.custom_config_engine_id
}

output "custom_config_engine_name" {
  description = "The name of the engine created."
  value       = module.custom_credential_engine.custom_config_engine_name
}

output "code_engine_key_ref" {
  description = "The IAM API key used by the credentials system to access the secrets manager instance."
  sensitive   = true
  value       = module.custom_credential_engine.code_engine_key_ref
}

output "secrets_manager_custom_credentials_configuration_schema" {
  description = "The schema that defines the format of the input and output parameters."
  value       = module.custom_credential_engine.secrets_manager_custom_credentials_configuration_schema
}
