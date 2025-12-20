########################################################################################################################
# Custom Credential Engine
########################################################################################################################

locals {
  prefix = var.prefix != null ? (trimspace(var.prefix) != "" ? "${trimspace(var.prefix)}-" : "") : ""
}

module "crn_parser" {
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.3.6"
  crn     = var.existing_secrets_manager_crn
}

locals {
  existing_secrets_manager_guid   = module.crn_parser.service_instance
  existing_secrets_manager_region = module.crn_parser.region
}

module "custom_credential_engine" {
  source                                       = "../.."
  secrets_manager_guid                         = local.existing_secrets_manager_guid
  secrets_manager_region                       = local.existing_secrets_manager_region
  custom_credential_engine_name                = "${local.prefix}${var.custom_credential_engine_name}"
  skip_secrets_manager_code_engine_auth_policy = var.skip_secrets_manager_code_engine_auth_policy
  endpoint_type                                = var.endpoint_type
  code_engine_project_id                       = var.existing_code_engine_project_id
  code_engine_job_name                         = var.existing_code_engine_job_name
  code_engine_region                           = var.existing_code_engine_region
  task_timeout                                 = var.task_timeout
  service_id_name                              = "${local.prefix}${var.service_id_name}"
  iam_credential_secret_name                   = "${local.prefix}${var.iam_credential_secret_name}"
  iam_credential_secret_group_id               = var.iam_credential_secret_group_id
  iam_credential_secret_ttl                    = var.iam_credential_secret_ttl
  iam_credential_secret_auto_rotation_interval = var.iam_credential_secret_auto_rotation_interval
  iam_credential_secret_auto_rotation_unit     = var.iam_credential_secret_auto_rotation_unit
  iam_credential_secret_labels                 = var.iam_credential_secret_labels
}
