# Terraform AWS codepipeline for serverless lambda



```
module "lambda_pipeline" {
  source                      = "git@github.com:trentearl/tf-cicd-node-lambda.git"

  organization_name           = var.organization_name
  repo_name                   = var.repo_name
  unit_test_buildspec         = "res/unit_test.yml"
  integration_test_buildspec  = "res/integration_test.yml"
  package_buildspec           = "res/package.yml"
  label                       = var.organization_name

  codebuild_env_variables     = var.codebuild_env_variables

}
```

