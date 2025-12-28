##############################################################################
# ServiceIDs and Policy
##############################################################################

resource "ibm_iam_service_id" "sm_service_id" {
  name        = var.service_id_name
  description = "ServiceID that can pull secrets from Secret Manager"
}

resource "ibm_iam_service_policy" "sm_service_id_policy" {
  iam_id = ibm_iam_service_id.sm_service_id.iam_id
  # iam_service_id = ibm_iam_service_id.sm_service_id.id
  roles = ["SecretsReader", "SecretTaskUpdater"]

  resources {
    service              = "secrets-manager"
    resource_instance_id = var.secrets_manager_guid
  }
}

resource "time_sleep" "wait_for_service_id" {
  depends_on      = [ibm_iam_service_id.sm_service_id, ibm_iam_service_policy.sm_service_id_policy]
  create_duration = "60s"
}

##############################################################################
# IAM Credential Secret
##############################################################################

module "sm_iam_credential_secret" {
  depends_on                           = [time_sleep.wait_for_service_id]
  source                               = "terraform-ibm-modules/iam-serviceid-apikey-secrets-manager/ibm"
  version                              = "1.2.16"
  region                               = var.secrets_manager_region
  secrets_manager_guid                 = var.secrets_manager_guid
  secret_group_id                      = var.iam_credential_secret_group_id
  sm_iam_secret_ttl                    = var.iam_credential_secret_ttl
  service_endpoints                    = var.endpoint_type
  serviceid_id                         = ibm_iam_service_id.sm_service_id.id
  sm_iam_secret_description            = "The iam credential secret to provides SM access to code engine job"
  sm_iam_secret_name                   = var.iam_credential_secret_name
  sm_iam_secret_api_key_persistence    = true # Set to true as a requirement to be used for custom credential
  sm_iam_secret_auto_rotation          = true # Set to true as a requirement to be used for custom credential
  sm_iam_secret_auto_rotation_interval = var.iam_credential_secret_auto_rotation_interval
  sm_iam_secret_auto_rotation_unit     = var.iam_credential_secret_auto_rotation_unit
  labels                               = var.iam_credential_secret_labels
}

##############################################################################
# Authorization Policy between Secrets Manager and Code Engine project
##############################################################################

resource "ibm_iam_authorization_policy" "sm_ce_policy" {
  count                       = var.skip_secrets_manager_code_engine_auth_policy ? 0 : 1
  source_service_name         = "secrets-manager"
  source_resource_instance_id = var.secrets_manager_guid
  target_service_name         = "codeengine"
  target_resource_instance_id = var.code_engine_project_id
  roles                       = ["Viewer", "Writer"]
}

# workaround for https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4478
resource "time_sleep" "wait_for_sm_ce_authorization_policy" {
  count           = var.skip_secrets_manager_code_engine_auth_policy ? 0 : 1
  depends_on      = [ibm_iam_authorization_policy.sm_ce_policy]
  create_duration = "30s"
}

##############################################################################
# Secrets Manager Custom Credentials Engine Module
##############################################################################

resource "ibm_sm_custom_credentials_configuration" "custom_credentials_configuration" {
  depends_on    = [time_sleep.wait_for_sm_ce_authorization_policy]
  instance_id   = var.secrets_manager_guid
  region        = var.secrets_manager_region
  name          = var.custom_credential_engine_name
  endpoint_type = var.endpoint_type
  api_key_ref   = module.sm_iam_credential_secret.secret_id
  code_engine {
    project_id = var.code_engine_project_id
    job_name   = var.code_engine_job_name
    region     = var.code_engine_region
  }
  task_timeout = var.task_timeout
}
