########################################################################################################################
# Input Variables
########################################################################################################################

variable "secrets_manager_guid" {
  type        = string
  description = "GUID of secrets manager instance to create the secret engine in."
}

variable "sm_region" {
  type        = string
  description = "The region of the secrets manager instance."
}

variable "custom_credential_engine_name" {
  type        = string
  description = "The name of the custom credentials engine to be created."
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

variable "iam_credentials_secret_id" {
  type        = string
  description = "The IAM credentials secret ID that is used for setting up a custom credentials secret configuration."
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
}
