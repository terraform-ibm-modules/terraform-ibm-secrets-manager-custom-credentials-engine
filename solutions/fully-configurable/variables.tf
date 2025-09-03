########################################################################################################################
# common variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key used to provision resources."
  sensitive   = true
}

variable "provider_visibility" {
  description = "Set the visibility value for the IBM terraform provider. Supported values are `public`, `private`, `public-and-private`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/guides/custom-service-endpoints)."
  type        = string
  default     = "private"
  nullable    = false

  validation {
    condition     = contains(["public", "private", "public-and-private"], var.provider_visibility)
    error_message = "Invalid value for 'provider_visibility'. Allowed values are 'public', 'private', or 'public-and-private'."
  }
}

variable "prefix" {
  type        = string
  nullable    = true
  description = "The prefix to be added to all resources created by this solution. To skip using a prefix, set this value to null or an empty string. The prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It should not exceed 16 characters, must not end with a hyphen('-'), and can not contain consecutive hyphens ('--'). Example: prod-us-south. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/prefix.md)."

  validation {
    # - null and empty string is allowed
    # - Must not contain consecutive hyphens (--): length(regexall("--", var.prefix)) == 0
    # - Starts with a lowercase letter: [a-z]
    # - Contains only lowercase letters (a–z), digits (0–9), and hyphens (-) and must not exceed 16 characters in length: [a-z0-9-]{0,14}
    # - Must not end with a hyphen (-): [a-z0-9]
    condition = (var.prefix == null || var.prefix == "" ? true :
      alltrue([
        can(regex("^[a-z][-a-z0-9]{0,14}[a-z0-9]$", var.prefix)),
        length(regexall("--", var.prefix)) == 0
      ])
    )
    error_message = "Prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It should not exceed 16 characters, must not end with a hyphen('-'), and cannot contain consecutive hyphens ('--')."
  }
}

variable "existing_secrets_manager_crn" {
  type        = string
  description = "The CRN of secrets manager instance to create the secret engine in."
  nullable    = false
}

########################################################################################################################
# custom credential engine variables
########################################################################################################################

variable "custom_credential_engine_name" {
  type        = string
  description = "The name of the custom credentials engine to be created."
}

variable "skip_secrets_manager_iam_auth_policy" {
  type        = bool
  description = "Whether to skip the creation of the IAM authorization policies required between the Code engine project and Secrets Manager instance(if you are using an existing Secrets Manager instance, attempting to re-create can cause conflicts if the policies already exist). If set to false, policies will be created that grants the Secrets Manager instance 'Viewer' and 'Writer' access to the Code engine project."
  default     = false
}

variable "endpoint_type" {
  type        = string
  description = "The endpoint type to communicate with the provided secrets manager instance. Possible values are `public` or `private`"
  default     = "public"

  validation {
    condition     = contains(["public", "private"], var.endpoint_type)
    error_message = "The specified endpoint_type is not a valid selection!"
  }
}

variable "existing_code_engine_project_id" {
  type        = string
  description = "The Project ID of the code engine project used by the custom credentials configuration. [Learn more](https://cloud.ibm.com/docs/codeengine?topic=codeengine-manage-project)"
}

variable "existing_code_engine_job_name" {
  type        = string
  description = "The code engine job name used by this custom credentials configuration. [Learn more](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-engine-custom-ce-job&interface=ui)"
}

variable "existing_code_engine_region" {
  type        = string
  description = "The region of the code engine project."
}

variable "task_timeout" {
  type        = string
  description = "The maximum allowed time for a code engine job to be completed."
  default     = "5m"

  validation {
    condition     = can(regex("^\\d+[smh]$", var.task_timeout))
    error_message = "task_timeout must be a string with a number followed by 's', 'm', or 'h' (e.g., '30s', '3m', '1h')."
  }
}

variable "service_id_name" {
  type        = string
  description = "The name of the service ID to be created to allow code engine job to pull secrets from Secrets Manager."
  default     = "custom-cred-engine-service-id"
}

variable "iam_credential_secret_name" {
  type        = string
  description = "The name of the IAM credential secret to allow code engine job to pull secrets from Secrets Manager."
  default     = "custom-cred-engine-iam-secret"
}

variable "iam_credential_secret_group_id" {
  type        = string
  description = "Secret Group ID of secret where IAM Secret will be added to, leave default (null) to add in default secret-group."
  default     = null #tfsec:ignore:GEN001
}

variable "iam_credential_secret_ttl" {
  type        = string
  description = "The validity / lease duration of ServiceID API key. Accepted values and formats are: SECONDS, Xm or Xh (where X is the number of minutes or hours appended to m or h respectively)."
  default     = "7776000" #tfsec:ignore:general-secrets-no-plaintext-exposure Default set to 90days
}

variable "iam_credential_secret_auto_rotation_interval" {
  type        = string
  description = "The rotation interval for the rotation policy."
  default     = 60

  validation {
    condition     = var.iam_credential_secret_auto_rotation_interval > 0
    error_message = "Value for `iam_credential_secret_auto_rotation_intervals` must be greater than 0 when auto-rotation is enabled."
  }
}

variable "iam_credential_secret_auto_rotation_unit" {
  type        = string
  description = "The unit of time for rotation policy. Acceptable values are `day` or `month`."
  default     = "day" #tfsec:ignore:general-secrets-no-plaintext-exposure

  validation {
    condition     = contains(["day", "month"], var.iam_credential_secret_auto_rotation_unit)
    error_message = "Value for `iam_credential_secret_auto_rotation_unit` must be either 'day' or 'month' when auto-rotation is enabled."
  }
}

variable "iam_credential_secret_labels" {
  type        = list(string)
  description = "Optional list of up to 30 labels to be created on the secret. Labels can be used to search for secrets in the Secrets Manager instance."
  default     = []
}
