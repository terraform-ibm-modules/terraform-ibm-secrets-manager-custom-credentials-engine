########################################################################################################################
# Input Variables
########################################################################################################################

variable "secrets_manager_guid" {
  type        = string
  description = "GUID of secrets manager instance to create the secret engine in."
}

variable "secrets_manager_region" {
  type        = string
  description = "The region of the secrets manager instance."
}

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
  description = "The endpoint type to communicate with the provided secrets manager instance. Possible values are `public` or `private`."
  default     = "public"
  validation {
    condition     = contains(["public", "private"], var.endpoint_type)
    error_message = "The specified endpoint_type is not a valid selection!"
  }
}

variable "code_engine_project_id" {
  type        = string
  description = "The Project ID of the code engine project used by the custom credentials configuration."
}

variable "code_engine_job_name" {
  type        = string
  description = "The code engine job name used by this custom credentials configuration."
}

variable "code_engine_region" {
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
}

variable "iam_credential_secret_name" {
  type        = string
  description = "The name of the IAM credential secret to allow code engine job to pull secrets from Secrets Manager."
}

variable "iam_credential_secret_group_id" {
  type        = string
  description = "Secret Group ID of secret where IAM Secret will be added to, leave default (null) to add in the default secret group."
  default     = null #tfsec:ignore:GEN001
}

variable "iam_credential_secret_ttl" {
  type        = string
  description = "Specify validity / lease duration of ServiceID API key. Accepted values and formats are: SECONDS, Xm or Xh (where X is the number of minutes or hours appended to m or h respectively)."
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
