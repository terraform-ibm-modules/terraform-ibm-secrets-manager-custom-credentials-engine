#! /bin/bash

############################################################################################################
## This script is used by the catalog pipeline to deploy the Code Engine
## which are the prerequisites for the fully-configurable custom credentials engine
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
    echo "prefix=\"cus-eng-$(openssl rand -hex 2)\""
  } >>${TF_VARS_FILE}
  terraform apply -input=false -auto-approve -var-file=${TF_VARS_FILE} || exit 1

  existing_code_engine_project_id="existing_code_engine_project_id"
  existing_code_engine_project_id_value=$(terraform output -state=terraform.tfstate -raw code_engine_project_id)
  existing_code_engine_job_name="existing_code_engine_job_name"
  existing_code_engine_job_name_value=$(terraform output -state=terraform.tfstate -raw code_engine_job_name)
  existing_code_engine_region="existing_code_engine_region"
  existing_code_engine_region_value=$(terraform output -state=terraform.tfstate -raw region)

  echo "Appending '${existing_code_engine_project_id}', '${existing_code_engine_job_name}' and '${existing_code_engine_region}' input variable values to ${JSON_FILE}.."

  cd "${cwd}"
  jq -r --arg existing_code_engine_project_id "${existing_code_engine_project_id}" \
    --arg existing_code_engine_project_id_value "${existing_code_engine_project_id_value}" \
    --arg existing_code_engine_job_name "${existing_code_engine_job_name}" \
    --arg existing_code_engine_job_name_value "${existing_code_engine_job_name_value}" \
    --arg existing_code_engine_region "${existing_code_engine_region}" \
    --arg existing_code_engine_region_value "${existing_code_engine_region_value}" \
    '. + {($existing_code_engine_project_id): $existing_code_engine_project_id_value, ($existing_code_engine_job_name): $existing_code_engine_job_name_value, ($existing_code_engine_region): $existing_code_engine_region_value}' "${JSON_FILE}" >tmpfile && mv tmpfile "${JSON_FILE}" || exit 1

  echo "Pre-validation complete successfully"
)
