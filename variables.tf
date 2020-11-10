variable "organization_name" {
  description = "The organization name provisioning the template (e.g. acme)"
}

variable "char_delimiter" {
  description = "The delimiter to use for unique names (default: -)"
  default     = "-"
}

variable "repo_name" {
  description = "The name of the repo"
}

variable "repo_default_branch" {
  description = "The name of the default repository branch (default: master)"
  default     = "master"
}

variable "environment" {
  description = "The environment being deployed (default: dev)"
  default     = "dev"
}

variable "build_timeout" {
  description = "The time to wait for a CodeBuild to complete before timing out in minutes (default: 5)"
  default     = "5"
}

variable "build_compute_type" {
  description = "The build instance type for CodeBuild (default: BUILD_GENERAL1_SMALL)"
  default     = "BUILD_GENERAL1_SMALL"
}

variable "build_image" {
  description = "The build image for CodeBuild to use (default: aws/codebuild/nodejs)"
  default     = "aws/codebuild/standard:4.0"
}

variable "build_privileged_override" {
  description = "Set the build privileged override to 'true' if you are not using a CodeBuild supported Docker base image. This is only relevant to building Docker images"
  default     = "false"
}

variable "unit_test_buildspec" {
  description = "The buildspec to be used for the Test stage (default: buildspec_test.yml)"
}

variable "integration_test_buildspec" {
  description = "The buildspec to be used for the Test stage (default: buildspec_test.yml)"
}

variable "package_buildspec" {
}

variable "label" {
}

variable "codebuild_env_variables" {
  type = list(object({
      name = string
      value = string
    })
  )
}
