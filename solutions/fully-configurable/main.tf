########################################################################################################################
# Custom Credential Engine
########################################################################################################################

locals {
  prefix = var.prefix != null ? trimspace(var.prefix) != "" ? "${var.prefix}-" : "" : ""
}

module "crn_parser" {
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.2.0"
  crn     = var.existing_secrets_manager_crn
}

locals {
  existing_secrets_manager_guid   = module.crn_parser.service_instance
  existing_secrets_manager_region = module.crn_parser.region

  #   crn_parts = split(":", data.ibm_sm_iam_credentials_secret.iam_secret.crn)
  #   secret_id = local.crn_parts[length(local.crn_parts) - 1]
}

resource "ibm_iam_authorization_policy" "sm_ce_policy" {
  source_service_name         = "secrets-manager"
  source_resource_instance_id = local.existing_secrets_manager_guid
  target_service_name         = "codeengine"
  target_resource_instance_id = var.code_engine_project_id
  roles                       = ["Viewer", "Writer"]
}

module "custom_credential_engine" {
  depends_on                    = [ibm_iam_authorization_policy.sm_ce_policy]
  source                        = "../.."
  secrets_manager_guid          = local.existing_secrets_manager_guid
  sm_region                     = local.existing_secrets_manager_region
  custom_credential_engine_name = "${local.prefix}-${var.custom_credential_engine_name}"
  endpoint_type                 = var.endpoint_type
  iam_credentials_secret_id     = var.iam_credentials_secret_id
  code_engine_project_id        = var.code_engine_project_id
  code_engine_job_name          = var.code_engine_job_name
  code_engine_region            = var.code_engine_region
  task_timeout                  = var.task_timeout
}
