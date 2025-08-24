# Complete example

An end-to-end complete example that will provision the following:
- A new resource group if one is not passed in.
- A new secrets manager instance with IAM credentials engine configured if an existing instance CRN is not passed.
- A new code engine project with code engine job.
- A custom credentials engine with IAM authorization policy for code engine job and IAM credential secret.
