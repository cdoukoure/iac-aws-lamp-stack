

resource "aws_codestarconnections_connection" "github" {
  name          = "github-connection"
  provider_type = "GitHub"
}

resource "aws_s3_bucket" "artifacts" {
  bucket        = "ci-cd-artifacts-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "codepipeline.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  role = aws_iam_role.codepipeline_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:*"]
        Effect   = "Allow"
        Resource = ["${aws_s3_bucket.artifacts.arn}/*"]
      },
      {
        Action   = ["codestar-connections:UseConnection"]
        Effect   = "Allow"
        Resource = aws_codestarconnections_connection.github.arn
      },
      {
        Action   = ["codebuild:*", "codedeploy:*"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "codedeploy_role" {
  name = "codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "codedeploy.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codedeploy" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRole"
}

resource "aws_codedeploy_app" "app" {
  name = var.github_repo_name
}

resource "aws_codedeploy_deployment_group" "ec2_autoscaling" {
  app_name              = aws_codedeploy_app.app.name
  deployment_group_name = "production"
  service_role_arn      = aws_iam_role.codedeploy_role.arn
  autoscaling_groups    = [var.autoscaling_group_name]

  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type   = "IN_PLACE"
  }

  ec2_tag_filter {
    key   = "Name"
    type  = "KEY_AND_VALUE"
    value = "web-server"
  }
}

resource "aws_codepipeline" "pipeline" {
  name     = var.github_repo_name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.artifacts.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "GitHub-Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        FullRepositoryId = "${var.github_repo_owner}/${var.github_repo_name}"
        BranchName       = var.github_repo_branch
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "EC2-Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["source"]
      version         = "1"

      configuration = {
        ApplicationName     = aws_codedeploy_app.app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.ec2_autoscaling.deployment_group_name
      }
    }
  }
}



