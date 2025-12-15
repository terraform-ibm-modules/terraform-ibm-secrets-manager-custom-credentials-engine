// Tests in this file are NOT run in the PR pipeline. They are run in the continuous testing pipeline along with the ones in pr_test.go
package test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/common"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
)

var validRegions = []string{
	"jp-osa",
	"au-syd",
	"jp-tok",
	"eu-de",
	"eu-gb",
	"eu-es",
	"us-south",
	"ca-mon",
	"ca-tor",
	"us-east",
	"br-sao",
}

func setupCompleteOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {
	options := testhelper.TestOptionsDefault(&testhelper.TestOptions{
		Testing:      t,
		TerraformDir: dir,
		Region:       validRegions[common.CryptoIntn(len(validRegions))],
		Prefix:       prefix,
	})

	// need to ignore because of a provider issue: https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4719
	options.IgnoreUpdates = testhelper.Exemptions{
		List: []string{
			"module.code_engine.module.job[\"" + options.Prefix + "-job\"].ibm_code_engine_job.ce_job",
		},
	}

	options.TerraformVars = map[string]interface{}{
		"prefix":             options.Prefix,
		"region":             options.Region,
		"existing_sm_guid":   permanentResources["secretsManagerGuid"],
		"existing_sm_region": permanentResources["secretsManagerRegion"],
	}

	return options
}

func TestRunAdvancedExample(t *testing.T) {
	t.Parallel()

	options := setupCompleteOptions(t, "custom-engine", completeExampleDir)

	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}
