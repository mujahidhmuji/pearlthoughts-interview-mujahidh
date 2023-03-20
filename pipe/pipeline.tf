resource "aws_codepipeline" "nodejs_app_pipeline" {
  name     = "nodejs-app-pipeline"
  role_arn = aws_iam_role.apps_codepipeline_role.arn
  tags = {
    Environment = var.env
  }

  artifact_store {
    location = var.artifacts_bucket_name
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      category = "Source"
      configuration = {
        "BranchName" = var.nodejs_project_repository_branch
        # "PollForSourceChanges" = "false"
        "RepositoryName" = aws_codecommit_repository.code_repo.repository_name
      }
      input_artifacts = []
      name            = "Source"
      output_artifacts = [
        "SourceArtifact",
      ]
      owner     = "AWS"
      provider  = "CodeCommit"
      run_order = 1
      version   = "1"
    }
  }
  stage {
    name = "Build"

    action {
      category = "Build"
      configuration = {
        "EnvironmentVariables" = jsonencode(
          [
            {
              name  = "environment"
              type  = "PLAINTEXT"
              value = var.env
            },
            {
              name  = "AWS_DEFAULT_REGION"
              type  = "PLAINTEXT"
              value = var.aws_region
            },
            {
              name  = "AWS_ACCOUNT_ID"
              type  = "PARAMETER_STORE"
              value = "ACCOUNT_ID"
            },
            {
              name  = "IMAGE_REPO_NAME"
              type  = "PLAINTEXT"
              value = aws_ecr_repository.nodejs_app_repo.name
            },
            {
              name  = "IMAGE_TAG"
              type  = "PLAINTEXT"
              value = "latest"
            },
            {
              name  = "CONTAINER_NAME"
              type  = "PLAINTEXT"
              value = var.container_name
            },
          ]
        )
        "ProjectName" = aws_codebuild_project.containerAppBuild.name
      }
      input_artifacts = [
        "SourceArtifact",
      ]
      name = "Build"
      output_artifacts = [
        "BuildArtifact",
      ]
      owner     = "AWS"
      provider  = "CodeBuild"
      run_order = 1
      version   = "1"
    }
  }
  stage {
    name = "Deploy"

    action {
      category = "Deploy"
      configuration = {
        "ClusterName" = aws_ecs_cluster.nodejs_app_cluster.name
        "ServiceName" = aws_ecs_service.nodejs_service.name
        "FileName"    = "imagedefinitions.json"
        #"DeploymentTimeout" = "15"
      }
      input_artifacts = [
        "BuildArtifact",
      ]
      name             = "Deploy"
      output_artifacts = []
      owner            = "AWS"
      provider         = "ECS"
      run_order        = 1
      version          = "1"
    }
  }

  depends_on = [
    aws_codebuild_project.containerAppBuild,
    aws_ecs_cluster.nodejs_app_cluster,
    aws_ecs_service.nodejs_service,
    aws_ecr_repository.nodejs_app_repo,
    aws_codecommit_repository.code_repo,
    aws_s3_bucket.cicd_bucket,
  ]
}