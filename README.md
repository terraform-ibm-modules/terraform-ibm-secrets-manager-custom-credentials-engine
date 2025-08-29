# Secrets Manager custom credentials engine module

[![Graduated (Supported)](https://img.shields.io/badge/Status-Graduated%20(Supported)-brightgreen)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-secrets-manager-custom-credentials-engine?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-secrets-manager-custom-credentials-engine/releases/latest)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

This module configures a custom credentials engine for a Secrets Manager instance. For more information about enabling Secrets Manager for custom credentials engine, see [Preparing to create custom credentials engine](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-custom-credentials-prepare).

The module handles the following components:

- [IAM service authorization]((https://cloud.ibm.com/docs/account?topic=account-serviceauth&interface=ui)) policy creation between Secrets Manager as source and Code Engine Project as target
- [IAM credentials secret](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-iam-credentials&interface=terraform) creation for allowing code engine job to fetch secrets
- [Custom credentials engine](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-custom-credentials-config&interface=terraform)

These components are needed in order to create the custom credentials secret in SM instance.


<!-- The following content is automatically populated by the pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-secrets-manager-custom-credentials-engine](#terraform-ibm-secrets-manager-custom-credentials-engine)
* [Examples](./examples)
    * [Complete example](./examples/complete)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->


## Reference architectures

Refer [here](./reference-architecture/secrets_manager_custom_credentials_engine.svg) for reference architecture.


## terraform-ibm-secrets-manager-custom-credentials-engine

### Usage

```hcl
module "custom_credential_engine" {
  source                                       = "terraform-ibm-modules/secrets-manager-custom-credentials-engine/ibm"
  version                                      = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  secrets_manager_guid                         = "<secrets_manager_instance_id>"
  secrets_manager_region                       = "<secrets_manager_instance_region>"
  custom_credential_engine_name                = "My Custom Credentials Engine"
  endpoint_type                                = "public"
  code_engine_project_id                       = "<code_engine_project_id>"
  code_engine_job_name                         = "<code_engine_project_job_name>"
  code_engine_region                           = "<code_engine_region>"
  task_timeout                                 = "5m"
  service_id_name                              = "My Service ID"
  iam_credential_secret_name                   = "My Credentials Secret"
}

```



### Required IAM access policies

You need the following permissions to run this module.

- Account Management
    - **IAM Identity** services
        - `Administrator` platform access
        - `Service ID Creator` service access
    - **All Identity and Access enabled** services
        - `Administrator` platform access
- IAM Services
    - **Secrets Manager** service
        - `Administrator` platform access
        - `Manager` service access

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.79.2, < 2.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1, < 1.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_sm_iam_credential_secret"></a> [sm\_iam\_credential\_secret](#module\_sm\_iam\_credential\_secret) | terraform-ibm-modules/iam-serviceid-apikey-secrets-manager/ibm | 1.2.0 |

### Resources

| Name | Type |
|------|------|
| [ibm_iam_authorization_policy.sm_ce_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_authorization_policy) | resource |
| [ibm_iam_service_id.sm_service_id](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_service_id) | resource |
| [ibm_iam_service_policy.sm_service_id_policy](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/iam_service_policy) | resource |
| [ibm_sm_custom_credentials_configuration.custom_credentials_configuration](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/sm_custom_credentials_configuration) | resource |
| [time_sleep.wait_for_service_id](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_code_engine_job_name"></a> [code\_engine\_job\_name](#input\_code\_engine\_job\_name) | The code engine job name used by this custom credentials configuration. | `string` | n/a | yes |
| <a name="input_code_engine_project_id"></a> [code\_engine\_project\_id](#input\_code\_engine\_project\_id) | The Project ID of the code engine project used by the custom credentials configuration. | `string` | n/a | yes |
| <a name="input_code_engine_region"></a> [code\_engine\_region](#input\_code\_engine\_region) | The region of the code engine project. | `string` | n/a | yes |
| <a name="input_custom_credential_engine_name"></a> [custom\_credential\_engine\_name](#input\_custom\_credential\_engine\_name) | The name of the custom credentials engine to be created. | `string` | n/a | yes |
| <a name="input_endpoint_type"></a> [endpoint\_type](#input\_endpoint\_type) | The endpoint type to communicate with the provided secrets manager instance. Possible values are `public` or `private`. | `string` | `"public"` | no |
| <a name="input_iam_credential_secret_auto_rotation_interval"></a> [iam\_credential\_secret\_auto\_rotation\_interval](#input\_iam\_credential\_secret\_auto\_rotation\_interval) | The rotation interval for the rotation policy. | `string` | `60` | no |
| <a name="input_iam_credential_secret_auto_rotation_unit"></a> [iam\_credential\_secret\_auto\_rotation\_unit](#input\_iam\_credential\_secret\_auto\_rotation\_unit) | The unit of time for rotation policy. Acceptable values are `day` or `month`. | `string` | `"day"` | no |
| <a name="input_iam_credential_secret_group_id"></a> [iam\_credential\_secret\_group\_id](#input\_iam\_credential\_secret\_group\_id) | Secret Group ID of secret where IAM Secret will be added to, leave default (null) to add in the default secret group. | `string` | `null` | no |
| <a name="input_iam_credential_secret_labels"></a> [iam\_credential\_secret\_labels](#input\_iam\_credential\_secret\_labels) | Optional list of up to 30 labels to be created on the secret. Labels can be used to search for secrets in the Secrets Manager instance. | `list(string)` | `[]` | no |
| <a name="input_iam_credential_secret_name"></a> [iam\_credential\_secret\_name](#input\_iam\_credential\_secret\_name) | The name of the IAM credential secret to allow code engine job to pull secrets from Secrets Manager. | `string` | n/a | yes |
| <a name="input_iam_credential_secret_ttl"></a> [iam\_credential\_secret\_ttl](#input\_iam\_credential\_secret\_ttl) | Specify validity / lease duration of ServiceID API key. Accepted values and formats are: SECONDS, Xm or Xh (where X is the number of minutes or hours appended to m or h respectively). | `string` | `"7776000"` | no |
| <a name="input_secrets_manager_guid"></a> [secrets\_manager\_guid](#input\_secrets\_manager\_guid) | GUID of secrets manager instance to create the secret engine in. | `string` | n/a | yes |
| <a name="input_secrets_manager_region"></a> [secrets\_manager\_region](#input\_secrets\_manager\_region) | The region of the secrets manager instance. | `string` | n/a | yes |
| <a name="input_service_id_name"></a> [service\_id\_name](#input\_service\_id\_name) | The name of the service ID to be created to allow code engine job to pull secrets from Secrets Manager. | `string` | n/a | yes |
| <a name="input_task_timeout"></a> [task\_timeout](#input\_task\_timeout) | The maximum allowed time for a code engine job to be completed. | `string` | `"5m"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_code_engine_key_ref"></a> [code\_engine\_key\_ref](#output\_code\_engine\_key\_ref) | The IAM API key used by the credentials system to access the secrets manager instance. |
| <a name="output_custom_config_engine_id"></a> [custom\_config\_engine\_id](#output\_custom\_config\_engine\_id) | The unique identifier of the engine created. |
| <a name="output_custom_config_engine_name"></a> [custom\_config\_engine\_name](#output\_custom\_config\_engine\_name) | The name of the engine created. |
| <a name="output_secrets_manager_custom_credentials_configuration_schema"></a> [secrets\_manager\_custom\_credentials\_configuration\_schema](#output\_secrets\_manager\_custom\_credentials\_configuration\_schema) | The schema that defines the format of the input and output parameters. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set-up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
