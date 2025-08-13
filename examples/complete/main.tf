##############################################################################
# Resource Group
##############################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.3.0"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

##############################################################################
# Code Engine
##############################################################################

module "code_engine" {
  source            = "terraform-ibm-modules/code-engine/ibm"
  version           = "4.5.7"
  resource_group_id = module.resource_group.resource_group_id
  project_name      = "${var.prefix}-project"
  jobs = {
    "${var.prefix}-job" = {
      image_reference = "icr.io/codeengine/helloworld"
      run_env_variables = [{
        type  = "literal"
        name  = "SMOUT_TEST"                 # The code engine job must have an environment variable of type SMOUT_XXX to be added to custom engine configuration
        value = "type:string, required:true" # The code engine job env variable must have a value containing the required:true attribute
      }]
      run_arguments = ["echo \"hello world\""]
      run_commands  = ["/bin/sh"]
    }
  }
}

########################################################################################################################
# Locals
########################################################################################################################

locals {
  sm_guid   = var.existing_sm_instance_guid == null ? module.secrets_manager[0].secrets_manager_guid : var.existing_sm_instance_guid
  sm_region = var.existing_sm_instance_region == null ? var.region : var.existing_sm_instance_region
}

##############################################################################
# Secrets Manager
##############################################################################

module "secrets_manager" {
  source               = "terraform-ibm-modules/secrets-manager/ibm"
  version              = "2.7.5"
  count                = var.existing_sm_instance_guid == null ? 1 : 0
  resource_group_id    = module.resource_group.resource_group_id
  region               = var.region
  secrets_manager_name = "${var.prefix}-secrets-manager"
  sm_service_plan      = "standard"
  allowed_network      = "public-and-private"
  sm_tags              = var.resource_tags
}

##############################################################################
# ServiceIDs and Policy
##############################################################################

resource "ibm_iam_service_id" "sm_service_id" {
  name        = "${var.prefix}-sm_custom_credential_service_id"
  description = "ServiceID that can pull secrets from Secret Manager"
}

resource "ibm_iam_service_policy" "sm_service_id_policy" {
  iam_service_id = ibm_iam_service_id.sm_service_id.id
  roles          = ["SecretsReader", "SecretTaskUpdater"]

  resources {
    service              = "secrets-manager"
    resource_instance_id = local.sm_guid
  }
}

resource "time_sleep" "wait_for_authorization_policy" {
  depends_on      = [ibm_iam_service_id.sm_service_id, ibm_iam_service_policy.sm_service_id_policy]
  create_duration = "30s"
}

##############################################################################
# IAM Credential Secret
##############################################################################

# module.secrets_manager is added in depends_on in order to prevent s2s auth policies from getting destroyed before sm_iam_credential_secret is destroyed
module "sm_iam_credential_secret" {
  depends_on                           = [time_sleep.wait_for_authorization_policy, module.secrets_manager]
  source                               = "terraform-ibm-modules/iam-serviceid-apikey-secrets-manager/ibm"
  version                              = "1.2.0"
  region                               = local.sm_region
  secrets_manager_guid                 = local.sm_guid
  serviceid_id                         = ibm_iam_service_id.sm_service_id.id
  sm_iam_secret_description            = "the iam credential secret to provides sm access to code engine"
  sm_iam_secret_name                   = "${var.prefix}-iam-secret-for-custom-credential"
  sm_iam_secret_api_key_persistence    = true # Set to true as a requirement to be used for custom credential
  sm_iam_secret_auto_rotation          = true # Set to true as a requirement to be used for custom credential
  sm_iam_secret_auto_rotation_interval = 60
  sm_iam_secret_auto_rotation_unit     = "day"
}

##############################################################################
# Authorization Policy between Code Engine project and secrets manager
##############################################################################

resource "ibm_iam_authorization_policy" "sm_ce_policy" {
  source_service_name         = "secrets-manager"
  source_resource_instance_id = local.sm_guid
  target_service_name         = "codeengine"
  target_resource_instance_id = module.code_engine.project_id
  roles                       = ["Viewer", "Writer"]
}

##############################################################################
# Custom Credentials Engine Instance
##############################################################################

module "custom_engine" {
  depends_on                    = [module.code_engine, module.sm_iam_credential_secret, ibm_iam_authorization_policy.sm_ce_policy]
  source                        = "../.."
  sm_guid                       = local.sm_guid
  sm_region                     = local.sm_region
  custom_credential_engine_name = "${var.prefix}-engine"
  iam_credentials_secret_id     = module.sm_iam_credential_secret.secret_id
  code_engine_project_id        = module.code_engine.project_id
  code_engine_job_name          = module.code_engine.job["${var.prefix}-job"].name
  code_engine_region            = var.region
  task_timeout                  = "5m"
}
