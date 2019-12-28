// Managed By : CloudDrove
// Description : This Terratest is used to test the Terraform VPC module.
// Copyright @ CloudDrove. All Right Reserved.

package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestAuroraPostgre(t *testing.T) {
	t.Parallel()

	terraformOptions := &terraform.Options{
		// Source path of Terraform directory.
		TerraformDir: "../../_example/aurora-postgre",
	}

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	clusterID := terraform.OutputList(t, terraformOptions, "rds_cluster_id")

	expectedClusterID := "test-clouddrove-postgres"
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedClusterID, clusterID[0])
}
