output "iam_role_codepipeline_role_arn" {
  value = aws_iam_role.codepipeline_role.arn
}

output "iam_role_codebuild_role_arn" {
  value = aws_iam_role.codebuild_role.arn
}

output "iam_role_codedeploy_role_arn" {
  value = aws_iam_role.codedeploy_role.arn
}