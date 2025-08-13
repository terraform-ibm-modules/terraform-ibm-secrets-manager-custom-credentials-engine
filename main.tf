##############################################################################
# Secrets Manager Custom Credentials Engine Module
##############################################################################

resource "ibm_sm_custom_credentials_configuration" "custom_credentials_configuration_instance" {
  instance_id   = var.sm_guid
  region        = var.sm_region
  name          = var.custom_credential_engine_name
  endpoint_type = var.endpoint_type
  api_key_ref   = var.iam_credentials_secret_id
  code_engine {
    project_id = var.code_engine_project_id
    job_name   = var.code_engine_job_name
    region     = var.code_engine_region
  }
  task_timeout = var.task_timeout
}
