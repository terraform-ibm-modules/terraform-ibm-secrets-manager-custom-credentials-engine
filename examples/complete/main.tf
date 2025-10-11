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
  version           = "4.6.2"
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
  sm_guid   = var.existing_sm_guid == null ? module.secrets_manager[0].secrets_manager_guid : var.existing_sm_guid
  sm_region = var.existing_sm_region == null ? var.region : var.existing_sm_region
}

##############################################################################
# Secrets Manager
##############################################################################

module "secrets_manager" {
  source               = "terraform-ibm-modules/secrets-manager/ibm"
  version              = "2.10.2"
  count                = var.existing_sm_guid == null ? 1 : 0
  resource_group_id    = module.resource_group.resource_group_id
  region               = var.region
  secrets_manager_name = "${var.prefix}-secrets-manager"
  sm_service_plan      = "standard"
  allowed_network      = "public-and-private"
  sm_tags              = var.resource_tags
}

##############################################################################
# Custom Credentials Engine Instance
##############################################################################

module "custom_engine" {
  depends_on                    = [module.code_engine, module.secrets_manager]
  source                        = "../.."
  secrets_manager_guid          = local.sm_guid
  secrets_manager_region        = local.sm_region
  custom_credential_engine_name = "${var.prefix}-engine"
  code_engine_project_id        = module.code_engine.project_id
  code_engine_job_name          = module.code_engine.job["${var.prefix}-job"].name
  code_engine_region            = var.region
  service_id_name               = "${var.prefix}-sm_custom_credential_service_id"
  iam_credential_secret_name    = "${var.prefix}-iam-secret-for-custom-credential"
}
