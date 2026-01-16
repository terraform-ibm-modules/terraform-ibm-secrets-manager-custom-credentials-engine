# Complete example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=secrets-manager-custom-credentials-engine-complete-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-secrets-manager-custom-credentials-engine/tree/main/examples/complete"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->


An end-to-end complete example that will provision the following:
- A new resource group if one is not passed in.
- A new secrets manager instance with IAM credentials engine configured if an existing instance CRN is not passed.
- A new code engine project with code engine job.
- A custom credentials engine with IAM authorization policy for code engine job and IAM credential secret.

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
