
# Rôle IAM pour CodeDeploy
resource "aws_iam_role" "codedeploy_role" {
  name = "${var.prefix}-ec2-codedeploy-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_instance_profile" "codedeploy_role" {
  name = "${var.prefix}-ec2-codedeploy-profile"
  role = aws_iam_role.codedeploy_role.name
}

resource "aws_iam_role_policy_attachment" "codedeploy" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforAWSCodeDeploy"
}

# Rôles IAM
resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "codepipeline.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role" "codebuild_role" {
  name = "codebuild-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "codebuild.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild" {
  role = aws_iam_role.codebuild_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}


# --- Stockage des Artéfacts ---
resource "aws_s3_bucket" "artifacts" {
  bucket = "ci-cd-artifacts-${random_id.suffix.hex}"
  acl    = "private"
}

resource "random_id" "suffix" {
  byte_length = 4
}

# --- CodeBuild ---
resource "aws_codebuild_project" "web_build" {
  name         = "web-app-build"
  service_role = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:6.0"
    type         = "LINUX_CONTAINER"
  }

  source {
    type = "CODEPIPELINE"
  }
}

# --- CodeDeploy ---
resource "aws_codedeploy_app" "web_app" {
  name = "web-app"
}

resource "aws_codedeploy_deployment_group" "web_group" {
  app_name              = aws_codedeploy_app.web_app.name
  deployment_group_name = "web-deploy-group"
  service_role_arn      = aws_iam_role.codedeploy_role.arn
  autoscaling_groups    = [var.autoscaling_group_name] # Passé depuis le module Auto Scaling

  deployment_style {
    deployment_type   = "IN_PLACE"
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
  }
}

# --- CodePipeline ---
resource "aws_codepipeline" "web_pipeline" {
  name     = "web-app-pipeline"
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
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner      = var.github_repo_owner
        Repo       = var.github_repo_name
        Branch     = "main"
        OAuthToken = var.github_token # Stocké dans AWS Secrets Manager
      }
    }
  }

  stage {
    name = "Build"
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.web_build.name
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ApplicationName     = aws_codedeploy_app.web_app.name
        DeploymentGroupName = aws_codedeploy_deployment_group.web_group.deployment_group_name
      }
    }
  }
}
