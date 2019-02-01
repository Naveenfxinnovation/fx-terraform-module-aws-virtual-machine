@Library('com.fxinnovation.fxinnovation-common-pipeline-library@feature/terraform-pipeline') _

fx_terraform(
  testEnvironmentCredentialId: 'itoa-application-awscollectors-awscred',
  terraformCommandTargets:     ['examples/standard-ec2-with-volume', 'examples/advanced-ec2-with-multiple-volumes']
)
