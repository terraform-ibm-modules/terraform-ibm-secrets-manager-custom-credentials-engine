<!-- Update this title with a descriptive name. Use sentence case. -->
# Secrets Manager custom credentials engine

<!--
Update status and "latest release" badges:
  1. For the status options, see https://terraform-ibm-modules.github.io/documentation/#/badge-status
  2. Update the "latest release" badge to point to the correct module's repo. Replace "terraform-ibm-module-template" in two places.
-->
[![Incubating (Not yet consumable)](https://img.shields.io/badge/status-Incubating%20(Not%20yet%20consumable)-red)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-secrets-manager-custom-credentials-engine?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-secrets-manager-custom-credentials-engine/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

<!--
Add a description of modules in this repo.
Expand on the repo short description in the .github/settings.yml file.

For information, see "Module names and descriptions" at
https://terraform-ibm-modules.github.io/documentation/#/implementation-guidelines?id=module-names-and-descriptions
-->

TODO: Replace this with a description of the modules in this repo.


<!-- The following content is automatically populated by the pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-secrets-manager-custom-credentials-engine](#terraform-ibm-secrets-manager-custom-credentials-engine)
* [Examples](./examples)
    * [Complete example](./examples/complete)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->


<!--
If this repo contains any reference architectures, uncomment the heading below and link to them.
(Usually in the `/reference-architectures` directory.)
See "Reference architecture" in the public documentation at
https://terraform-ibm-modules.github.io/documentation/#/implementation-guidelines?id=reference-architecture
-->
<!-- ## Reference architectures -->


<!-- Replace this heading with the name of the root level module (the repo name) -->
## terraform-ibm-secrets-manager-custom-credentials-engine

### Usage

<!--
Add an example of the use of the module in the following code block.

Use real values instead of "var.<var_name>" or other placeholder values
unless real values don't help users know what to change.
-->

```hcl
terraform {
  required_version = ">= 1.9.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "X.Y.Z"  # Lock into a provider version that satisfies the module constraints
    }
  }
}

locals {
    region = "us-south"
}

provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX"  # replace with apikey value
  region           = local.region
}

module "module_template" {
  source            = "terraform-ibm-modules/<replace>/ibm"
  version           = "X.Y.Z" # Replace "X.Y.Z" with a release version to lock into a specific release
  region            = local.region
  name              = "instance-name"
  resource_group_id = "xxXXxxXXxXxXXXXxxXxxxXXXXxXXXXX" # Replace with the actual ID of resource group to use
}
```

### Required access policies

<!-- PERMISSIONS REQUIRED TO RUN MODULE
If this module requires permissions, uncomment the following block and update
the sample permissions, following the format.
Replace the 'Sample IBM Cloud' service and roles with applicable values.
The required information can usually be found in the services official
IBM Cloud documentation.
To view all available service permissions, you can go in the
console at Manage > Access (IAM) > Access groups and click into an existing group
(or create a new one) and in the 'Access' tab click 'Assign access'.
-->

<!--
You need the following permissions to run this module:

- Service
    - **Resource group only**
        - `Viewer` access on the specific resource group
    - **Sample IBM Cloud** service
        - `Editor` platform access
        - `Manager` service access
-->

<!-- NO PERMISSIONS FOR MODULE
If no permissions are required for the module, uncomment the following
statement instead the previous block.
-->

<!-- No permissions are needed to run this module.-->


<!-- The following content is automatically populated by the pre-commit hook -->
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
| [ibm_sm_custom_credentials_configuration.custom_credentials_configuration_instance](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/resources/sm_custom_credentials_configuration) | resource |
| [time_sleep.wait_for_service_id](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_code_engine_job_name"></a> [code\_engine\_job\_name](#input\_code\_engine\_job\_name) | The code engine job name used by this custom credentials configuration. | `string` | n/a | yes |
| <a name="input_code_engine_project_id"></a> [code\_engine\_project\_id](#input\_code\_engine\_project\_id) | The Project ID of the code engine project used by the custom credentials configuration. | `string` | n/a | yes |
| <a name="input_code_engine_region"></a> [code\_engine\_region](#input\_code\_engine\_region) | The region of the code engine project. | `string` | n/a | yes |
| <a name="input_custom_credential_engine_name"></a> [custom\_credential\_engine\_name](#input\_custom\_credential\_engine\_name) | The name of the custom credentials engine to be created. | `string` | n/a | yes |
| <a name="input_endpoint_type"></a> [endpoint\_type](#input\_endpoint\_type) | The endpoint type to communicate with the provided secrets manager instance. Possible values are `public` or `private`. | `string` | `"public"` | no |
| <a name="input_iam_credential_secret_auto_rotation_interval"></a> [iam\_credential\_secret\_auto\_rotation\_interval](#input\_iam\_credential\_secret\_auto\_rotation\_interval) | Specifies the rotation interval for the rotation policy. | `string` | `60` | no |
| <a name="input_iam_credential_secret_auto_rotation_unit"></a> [iam\_credential\_secret\_auto\_rotation\_unit](#input\_iam\_credential\_secret\_auto\_rotation\_unit) | Specifies the unit of time for rotation policy. Acceptable values are `day` or `month`. | `string` | `"day"` | no |
| <a name="input_iam_credential_secret_group_id"></a> [iam\_credential\_secret\_group\_id](#input\_iam\_credential\_secret\_group\_id) | Secret Group ID of secret where IAM Secret will be added to, leave default (null) to add in default secret-group. | `string` | `null` | no |
| <a name="input_iam_credential_secret_labels"></a> [iam\_credential\_secret\_labels](#input\_iam\_credential\_secret\_labels) | Optional list of up to 30 labels to be created on the secret. Labels can be used to search for secrets in the Secrets Manager instance. | `list(string)` | `[]` | no |
| <a name="input_iam_credential_secret_name"></a> [iam\_credential\_secret\_name](#input\_iam\_credential\_secret\_name) | The name of the IAM credential secret to allow code engine job to pull secrets from SM. | `string` | n/a | yes |
| <a name="input_iam_credential_secret_ttl"></a> [iam\_credential\_secret\_ttl](#input\_iam\_credential\_secret\_ttl) | Specify validity / lease duration of ServiceID API key. Accepted values and formats are: SECONDS, Xm or Xh (where X is the number of minutes or hours appended to m or h respectively). | `string` | `"7776000"` | no |
| <a name="input_service_id_name"></a> [service\_id\_name](#input\_service\_id\_name) | The name of the service ID to be created to allow code engine job to pull secrets from SM. | `string` | n/a | yes |
| <a name="input_sm_guid"></a> [sm\_guid](#input\_sm\_guid) | GUID of secrets manager instance to create the secret engine in. | `string` | n/a | yes |
| <a name="input_sm_region"></a> [sm\_region](#input\_sm\_region) | The region of the secrets manager instance. | `string` | n/a | yes |
| <a name="input_task_timeout"></a> [task\_timeout](#input\_task\_timeout) | The maximum allowed time for a code engine job to be completed. | `string` | `"5m"` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_code_engine_key_ref"></a> [code\_engine\_key\_ref](#output\_code\_engine\_key\_ref) | The IAM API key used by the credentials system to access the secrets manager instance. |
| <a name="output_custom_config_engine_id"></a> [custom\_config\_engine\_id](#output\_custom\_config\_engine\_id) | The unique identifier of the engine created. |
| <a name="output_custom_config_engine_name"></a> [custom\_config\_engine\_name](#output\_custom\_config\_engine\_name) | The name of the engine created. |
| <a name="output_sm_custom_credentials_configuration_schema"></a> [sm\_custom\_credentials\_configuration\_schema](#output\_sm\_custom\_credentials\_configuration\_schema) | The schema that defines the format of the input and output parameters. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set-up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
