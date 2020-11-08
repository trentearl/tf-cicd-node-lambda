resource "aws_s3_bucket" "build_artifact_bucket" {
  bucket        = "${var.label}-artifact-bucket"
  acl           = "private"
  force_destroy = var.force_artifact_destroy
}

resource "aws_kms_key" "artifact_encryption_key" {
  description             = "artifact-encryption-key"
  deletion_window_in_days = 10
}

resource "aws_codepipeline" "codepipeline" {
  name     = var.repo_name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.build_artifact_bucket.bucket
    type     = "S3"

    encryption_key {
      id   = aws_kms_key.artifact_encryption_key.arn
      type = "KMS"
    }
  }

  stage {
    name = "source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        RepositoryName = var.repo_name
        BranchName     = var.repo_default_branch
      }
    }
  }

  stage {
    name = "unit-test"

    action {
      name             = "unit-test"
      category         = "Test"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source"]
      version          = "1"

      configuration = {
        ProjectName = "${aws_codebuild_project.unit_test.name}"
      }
    }
  }

  stage {
    name = "integration-test"

    action {
      name             = "integration-test"
      category         = "Test"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source"]
      version          = "1"

      configuration = {
        ProjectName = "${aws_codebuild_project.integration_test.name}"
      }
    }
  }


  stage {
    name = "Package"

    action {
      name             = "Package"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source"]
      output_artifacts = ["packaged"]
      version          = "1"

      configuration = {
        ProjectName = "${aws_codebuild_project.package.name}"
      }
    }
  }

}

resource "aws_codebuild_project" "unit_test" {
  name           = "${var.repo_name}-unit-test"
  description    = "Unit test for ${var.repo_name}"
  service_role   = aws_iam_role.codebuild.arn
  build_timeout  = var.build_timeout
  encryption_key = aws_kms_key.artifact_encryption_key.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = var.build_compute_type
    image           = var.build_image
    type            = "LINUX_CONTAINER"
    privileged_mode = var.build_privileged_override
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.unit_test_buildspec
  }
}

resource "aws_codebuild_project" "integration_test" {
  name           = "${var.repo_name}-integration-test"
  description    = "Integration test ${var.repo_name}"
  service_role   = aws_iam_role.codebuild.arn
  build_timeout  = var.build_timeout
  encryption_key = aws_kms_key.artifact_encryption_key.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = var.build_compute_type
    image           = var.build_image
    type            = "LINUX_CONTAINER"
    privileged_mode = var.build_privileged_override

    dynamic "environment_variable" {
      for_each = var.codebuild_env_variables
      content {
        name = environment_variable.value.name
        value = environment_variable.value.value
      }
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.integration_test_buildspec
  }
}


resource "aws_codebuild_project" "package" {
  name           = "${var.repo_name}-package"
  description    = "Package ${var.repo_name}"
  service_role   = aws_iam_role.codebuild.arn
  build_timeout  = var.build_timeout
  encryption_key = aws_kms_key.artifact_encryption_key.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = var.build_compute_type
    image           = var.build_image
    type            = "LINUX_CONTAINER"
    privileged_mode = var.build_privileged_override
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.package_buildspec
  }
}


