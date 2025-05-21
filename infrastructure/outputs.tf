output "s3_bucket_name" {
  value = module.ci_cd_pipeline.s3_bucket_name
}

output "codedeploy_group_name" {
  value = module.ci_cd_pipeline.codedeploy_group_name
}