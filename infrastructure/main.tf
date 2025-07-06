module "vpc" {
  source = "./modules/vpc"
  prefix = var.prefix
}

module "rds_mysql" {
  depends_on = [
    module.vpc,
  ]
  source                    = "./modules/rds_mysql"
  prefix                    = var.prefix
  db_instance_class         = var.rds_mysql_db_instance_class
  db_master_username        = var.rds_mysql_db_master_username
  db_master_password        = var.rds_mysql_db_master_password
  db_subnet_ids             = module.vpc.subnet_private_ids
  db_vpc_security_group_ids = [module.vpc.sg_rds_mysql_id]
}

module "ec2_autoscaling" {
  depends_on = [
    module.vpc,
  ]
  source                          = "./modules/ec2_autoscaling"
  prefix                          = var.prefix
  region                          = var.region
  vpc_id                          = module.vpc.vpc_id
  vpc_zone_identifier             = module.vpc.subnet_private_ids
  web_security_group_id           = module.vpc.sg_ec2_web_id
  aws_lb_target_group_ec2_web_arn = module.vpc.lb_target_group_ec2_web_arn
  ec2_web_key_name                = var.ec2_autoscaling_key_name
  ec2_web_instance_type           = var.ec2_autoscaling_instance_type
  ec2_web_min_instance            = var.ec2_autoscaling_min_instance
  ec2_web_max_instance            = var.ec2_autoscaling_max_instance
  ec2_web_domain_name             = var.ec2_autoscaling_web_domain_name
}


module "monitoring" {
  depends_on = [
    module.vpc,
    module.ec2_autoscaling,
    module.rds_mysql
  ]
  source                          = "./modules/cloudwatch"
  prefix                          = var.prefix
  region                          = var.region
  autoscaling_group_name          = module.ec2_autoscaling.group_name
  autoscaling_group_ec2_role_id   = module.ec2_autoscaling.role_id
  autoscaling_group_image_id      = module.ec2_autoscaling.image_id
  autoscaling_group_instance_type = var.ec2_autoscaling_instance_type
  db_instance_identifier          = module.rds_mysql.identifier
  db_instance_enable_replica      = var.cloudwatch_db_instance_enable_replica
  email_for_alert                 = var.cloudwatch_email_for_alert
}

module "ci_cd_pipeline" {
  depends_on = [
    module.vpc,
    module.ec2_autoscaling
  ]
  source                 = "./modules/ci_cd_pipeline"
  prefix                 = var.prefix
  autoscaling_group_name = module.ec2_autoscaling.group_name
  github_repo_owner      = var.devops_github_repo_owner
  github_repo_name       = var.devops_github_repo_name
  github_token           = var.devops_github_token
}

//*/
