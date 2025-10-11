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
