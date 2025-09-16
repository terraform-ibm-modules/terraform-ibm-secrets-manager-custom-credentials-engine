// Tests in this file are run in the PR pipeline and the continuous testing pipeline
package test

import (
	"fmt"
	"log"
	"os"
	"strings"
	"testing"

	"github.com/gruntwork-io/terratest/modules/files"
	"github.com/gruntwork-io/terratest/modules/logger"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
)

const completeExampleDir = "examples/complete"
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"
const fullyConfigFlavorDir = "solutions/fully-configurable"

var permanentResources map[string]interface{}

// TestMain will be run before any parallel tests, used to read data from yaml for use with tests
func TestMain(m *testing.M) {
	var err error
	permanentResources, err = common.LoadMapFromYaml(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}

	os.Exit(m.Run())
}

func provisionPreReq(t *testing.T, p string) (string, *terraform.Options, error) {
	// ------------------------------------------------------------------------------------
	// Provision existing resources first
	// ------------------------------------------------------------------------------------
	prefix := fmt.Sprintf("%s-%s", p, strings.ToLower(random.UniqueId()))
	realTerraformDir := "./existing-resources"
	tempTerraformDir, _ := files.CopyTerraformFolderToTemp(realTerraformDir, fmt.Sprintf(prefix+"-%s", strings.ToLower(random.UniqueId())))

	// Verify ibmcloud_api_key variable is set
	checkVariable := "TF_VAR_ibmcloud_api_key"
	val, present := os.LookupEnv(checkVariable)
	require.True(t, present, checkVariable+" environment variable not set")
	require.NotEqual(t, "", val, checkVariable+" environment variable is empty")

	logger.Log(t, "Tempdir: ", tempTerraformDir)
	existingTerraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: tempTerraformDir,
		Vars: map[string]interface{}{
			"prefix": prefix,
		},
		// Set Upgrade to true to ensure latest version of providers and modules are used by terratest.
		// This is the same as setting the -upgrade=true flag with terraform.
		Upgrade: true,
	})

	terraform.WorkspaceSelectOrNew(t, existingTerraformOptions, prefix)
	_, existErr := terraform.InitAndApplyE(t, existingTerraformOptions)
	if existErr != nil {
		// assert.True(t, existErr == nil, "Init and Apply of temp existing resource failed")
		return "", nil, existErr
	}
	return prefix, existingTerraformOptions, nil
}

func TestRunSolutionsFullyConfigurableSchematics(t *testing.T) {
	t.Parallel()

	prefix, existingTerraformOptions, existErr := provisionPreReq(t, "cus-eng")

	if existErr != nil {
		assert.True(t, existErr == nil, "Init and Apply of temp existing resource failed")
	} else {
		// ------------------------------------------------------------------------------------
		// Deploy DA
		// ------------------------------------------------------------------------------------
		options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
			Testing: t,
			Prefix:  prefix,
			TarIncludePatterns: []string{
				"*.tf",
				fullyConfigFlavorDir + "/*.tf",
			},
			TemplateFolder:         fullyConfigFlavorDir,
			Tags:                   []string{"custom-config-test"},
			DeleteWorkspaceOnFail:  false,
			WaitJobCompleteMinutes: 60,
		})

		options.TerraformVars = []testschematic.TestSchematicTerraformVar{
			{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
			{Name: "prefix", Value: terraform.Output(t, existingTerraformOptions, "prefix"), DataType: "string"},
			{Name: "existing_secrets_manager_crn", Value: permanentResources["secretsManagerCRN"], DataType: "string"},
			{Name: "custom_credential_engine_name", Value: "test-engine", DataType: "string"},
			{Name: "existing_code_engine_project_id", Value: terraform.Output(t, existingTerraformOptions, "code_engine_project_id"), DataType: "string"},
			{Name: "existing_code_engine_job_name", Value: terraform.Output(t, existingTerraformOptions, "code_engine_job_name"), DataType: "string"},
			{Name: "existing_code_engine_region", Value: terraform.Output(t, existingTerraformOptions, "region"), DataType: "string"},
			{Name: "service_id_name", Value: "test-service-id", DataType: "string"},
			{Name: "iam_credential_secret_name", Value: "test-cred-secret", DataType: "string"},
		}

		// need to ignore because of a provider issue: https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4719
		options.IgnoreUpdates = testhelper.Exemptions{
			List: []string{
				"module.code_engine.module.job[\"" + options.Prefix + "-job\"].ibm_code_engine_job.ce_job",
			},
		}
		err := options.RunSchematicTest()
		assert.Nil(t, err, "This should not have errored")
	}

	// Check if "DO_NOT_DESTROY_ON_FAILURE" is set
	envVal, _ := os.LookupEnv("DO_NOT_DESTROY_ON_FAILURE")
	// Destroy the temporary existing resources if required
	if t.Failed() && strings.ToLower(envVal) == "true" {
		fmt.Println("Terratest failed. Debug the test and delete resources manually.")
	} else {
		logger.Log(t, "START: Destroy (prereq resources)")
		terraform.Destroy(t, existingTerraformOptions)
		terraform.WorkspaceDelete(t, existingTerraformOptions, prefix)
		logger.Log(t, "END: Destroy (prereq resources)")
	}
}

func TestRunSolutionsFullyConfigurableUpgradeSchematics(t *testing.T) {
	t.Parallel()

	prefix, existingTerraformOptions, existErr := provisionPreReq(t, "cus-upg")

	if existErr != nil {
		assert.True(t, existErr == nil, "Init and Apply of temp existing resource failed")
	} else {
		// ------------------------------------------------------------------------------------
		// Deploy DA
		// ------------------------------------------------------------------------------------
		options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
			Testing: t,
			Prefix:  prefix,
			TarIncludePatterns: []string{
				"*.tf",
				fullyConfigFlavorDir + "/*.tf",
			},
			TemplateFolder:         fullyConfigFlavorDir,
			Tags:                   []string{"custom-config-test"},
			DeleteWorkspaceOnFail:  false,
			WaitJobCompleteMinutes: 60,
		})

		options.TerraformVars = []testschematic.TestSchematicTerraformVar{
			{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
			{Name: "prefix", Value: terraform.Output(t, existingTerraformOptions, "prefix"), DataType: "string"},
			{Name: "existing_secrets_manager_crn", Value: permanentResources["secretsManagerCRN"], DataType: "string"},
			{Name: "custom_credential_engine_name", Value: "test-engine", DataType: "string"},
			{Name: "existing_code_engine_project_id", Value: terraform.Output(t, existingTerraformOptions, "code_engine_project_id"), DataType: "string"},
			{Name: "existing_code_engine_job_name", Value: terraform.Output(t, existingTerraformOptions, "code_engine_job_name"), DataType: "string"},
			{Name: "existing_code_engine_region", Value: terraform.Output(t, existingTerraformOptions, "region"), DataType: "string"},
			{Name: "service_id_name", Value: "test-service-id", DataType: "string"},
			{Name: "iam_credential_secret_name", Value: "test-cred-secret", DataType: "string"},
		}

		// need to ignore because of a provider issue: https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4719
		options.IgnoreUpdates = testhelper.Exemptions{
			List: []string{
				"module.code_engine.module.job[\"" + options.Prefix + "-job\"].ibm_code_engine_job.ce_job",
			},
		}
		err := options.RunSchematicUpgradeTest()
		assert.Nil(t, err, "This should not have errored")
	}

	// Check if "DO_NOT_DESTROY_ON_FAILURE" is set
	envVal, _ := os.LookupEnv("DO_NOT_DESTROY_ON_FAILURE")
	// Destroy the temporary existing resources if required
	if t.Failed() && strings.ToLower(envVal) == "true" {
		fmt.Println("Terratest failed. Debug the test and delete resources manually.")
	} else {
		logger.Log(t, "START: Destroy (prereq resources)")
		terraform.Destroy(t, existingTerraformOptions)
		terraform.WorkspaceDelete(t, existingTerraformOptions, prefix)
		logger.Log(t, "END: Destroy (prereq resources)")
	}
}
