# Complete example

<!--
The complete example should call the module(s) stored in this repository with a basic configuration.
Note, there is a pre-commit hook that will take the title of each example and include it in the repos main README.md.
The text below should describe exactly what resources are provisioned / configured by the example.
-->

An end-to-end complete example that will provision the following:
- A new resource group if one is not passed in.
- A new secrets manager instance with IAM credentials engine configured if an existing instance CRN is not passed.
- A new code engine project with code engine job.
- A custom credentials engine with IAM authorization policy for code engine job and IAM credential secret.
