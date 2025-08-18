#! /bin/bash

############################################################################################################
## This script is used by the catalog pipeline to deploy the VPC
## which are the prerequisites for the fully-configurable vsi
############################################################################################################

set -e

DA_DIR="solutions/fully-configurable"
TERRAFORM_SOURCE_DIR="tests/existing-resources"
JSON_FILE="${DA_DIR}/catalogValidationValues.json"
REGION="us-south"
TF_VARS_FILE="terraform.tfvars"

(
  cwd=$(pwd)
  cd ${TERRAFORM_SOURCE_DIR}
  echo "Provisioning prerequisite code engine.."
  terraform init || exit 1
  # $VALIDATION_APIKEY is available in the catalog runtime
  {
    echo "ibmcloud_api_key=\"${VALIDATION_APIKEY}\""
    echo "region=\"${REGION}\""
    echo "prefix=\"vsi-$(openssl rand -hex 2)\""
  } >>${TF_VARS_FILE}
  terraform apply -input=false -auto-approve -var-file=${TF_VARS_FILE} || exit 1

  code_engine_project_id="code_engine_project_id"
  code_engine_project_id_value=$(terraform output -state=terraform.tfstate -raw code_engine_project_id)
  code_engine_job_name="code_engine_job_name"
  code_engine_job_name_value=$(terraform output -state=terraform.tfstate -raw code_engine_job_name)
  code_engine_region="code_engine_region"
  code_engine_region_value=$(terraform output -state=terraform.tfstate -raw region)

  echo "Appending '${code_engine_project_id}', '${code_engine_job_name}' and '${code_engine_region}' input variable values to ${JSON_FILE}.."

  cd "${cwd}"
  jq -r --arg code_engine_project_id "${code_engine_project_id}" \
    --arg code_engine_project_id_value "${code_engine_project_id_value}" \
    --arg code_engine_job_name "${code_engine_job_name}" \
    --arg code_engine_job_name_value "${code_engine_job_name_value}" \
    --arg code_engine_region "${code_engine_region}" \
    --arg code_engine_region_value "${code_engine_region_value}" \
    '. + {($code_engine_project_id): $code_engine_project_id_value, ($code_engine_job_name): $code_engine_job_name_value, ($code_engine_region): $code_engine_region_value}' "${JSON_FILE}" >tmpfile && mv tmpfile "${JSON_FILE}" || exit 1

  echo "Pre-validation complete successfully"
)
