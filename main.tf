# Main Terraform configuration for HEAL MVP
# This file orchestrates all the modules in the correct order

# 1. KMS and IAM/Secrets (foundation)
module "kms" {
  source = "./modules/kms"
  
  name_prefix = local.name_prefix
  common_tags = local.common_tags
}

module "iam_secrets" {
  source = "./modules/iam"
  
  name_prefix = local.name_prefix
  common_tags = local.common_tags
  kms_key_arns = module.kms.key_arns
  
  dhis2_base_url  = var.dhis2_base_url
  dhis2_username  = var.dhis2_username
  dhis2_password  = var.dhis2_password
  notification_email = var.notification_email
}

# 2. Networking and Security
module "networking" {
  source = "./modules/networking"
  
  name_prefix = local.name_prefix
  common_tags = local.common_tags
  availability_zones = local.availability_zones
  allowed_cidr_blocks = var.allowed_cidr_blocks
}

module "security" {
  source = "./modules/security"
  
  name_prefix = local.name_prefix
  common_tags = local.common_tags
  vpc_id = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  public_subnet_ids = module.networking.public_subnet_ids
}

# 3. Storage and Data Lake
module "storage" {
  source = "./modules/s3"
  
  name_prefix = local.name_prefix
  common_tags = local.common_tags
  bucket_names = local.bucket_names
  kms_key_arn = module.kms.key_arns["s3_data"]
  
  depends_on = [module.kms]
}

# 4. Glue and Catalog
module "glue" {
  source = "./modules/glue"
  
  name_prefix = local.name_prefix
  common_tags = local.common_tags
  bucket_names = module.storage.bucket_names
  kms_key_arn = module.kms.key_arns["glue"]
  glue_role_arn = module.iam_secrets.glue_role_arn
  
  depends_on = [module.storage, module.iam_secrets]
}

# 5. Lake Formation (optional)
module "lake_formation" {
  count = var.enable_lake_formation ? 1 : 0
  source = "./modules/lake_formation"
  
  name_prefix = local.name_prefix
  common_tags = local.common_tags
  bucket_names = module.storage.bucket_names
  glue_role_arn = module.iam_secrets.glue_role_arn
  
  depends_on = [module.glue]
}

# 6. Athena
module "athena" {
  source = "./modules/athena"
  
  name_prefix = local.name_prefix
  common_tags = local.common_tags
  bucket_names = module.storage.bucket_names
  kms_key_arn = module.kms.key_arns["s3_data"]
  
  depends_on = [module.storage]
}

# 7. Redshift Serverless
module "redshift" {
  source = "./modules/redshift"
  
  name_prefix = local.name_prefix
  common_tags = local.common_tags
  private_subnet_ids = module.networking.private_subnet_ids
  kms_key_arn = module.kms.key_arns["redshift"]
  redshift_role_arn = module.iam_secrets.redshift_role_arn
  base_capacity = var.redshift_base_capacity
  
  depends_on = [module.networking, module.iam_secrets]
}

# 8. Lambda Functions
module "lambda" {
  source = "./modules/lambda"
  
  name_prefix = local.name_prefix
  common_tags = local.common_tags
  bucket_names = module.storage.bucket_names
  kms_key_arns = module.kms.key_arns
  lambda_role_arns = module.iam_secrets.lambda_role_arns
  redshift_endpoint = module.redshift.endpoint
  cognito_user_pool_id = module.cognito.user_pool_id
  
  depends_on = [module.storage, module.iam_secrets, module.redshift]
}

# 9. API Gateway and Cognito
module "cognito" {
  source = "./modules/cognito"
  
  name_prefix = local.name_prefix
  common_tags = local.common_tags
  domain_name = var.domain_name
}

module "api_gateway" {
  source = "./modules/api_gateway"
  
  name_prefix = local.name_prefix
  common_tags = local.common_tags
  lambda_function_arns = module.lambda.function_arns
  cognito_user_pool_arn = module.cognito.user_pool_arn
  cognito_user_pool_client_id = module.cognito.user_pool_client_id
  
  depends_on = [module.lambda, module.cognito]
}

# 10. Eventing and Orchestration
module "eventing" {
  source = "./modules/eventing"
  
  name_prefix = local.name_prefix
  common_tags = local.common_tags
  lambda_function_arns = module.lambda.function_arns
  bucket_names = module.storage.bucket_names
  sns_topic_arn = module.monitoring.sns_topic_arn
  
  depends_on = [module.lambda, module.storage, module.monitoring]
}

# 11. SageMaker (optional)
module "sagemaker" {
  count = var.enable_sagemaker ? 1 : 0
  source = "./modules/sagemaker"
  
  name_prefix = local.name_prefix
  common_tags = local.common_tags
  bucket_names = module.storage.bucket_names
  sagemaker_role_arn = module.iam_secrets.sagemaker_role_arn
  
  depends_on = [module.storage, module.iam_secrets]
}

# 12. QuickSight (optional)
module "quicksight" {
  count = var.enable_quicksight ? 1 : 0
  source = "./modules/quicksight"
  
  name_prefix = local.name_prefix
  common_tags = local.common_tags
  redshift_endpoint = module.redshift.endpoint
  quicksight_role_arn = module.iam_secrets.quicksight_role_arn
  
  depends_on = [module.redshift, module.iam_secrets]
}

# 13. Web Hosting
module "web_hosting" {
  source = "./modules/web_hosting"
  
  name_prefix = local.name_prefix
  common_tags = local.common_tags
  domain_name = var.domain_name
  web_bucket_name = module.storage.bucket_names["web_hosting"]
  
  providers = {
    aws.us_east_1 = aws.us_east_1
  }
  
  depends_on = [module.storage]
}

# 14. Monitoring and Logging
module "monitoring" {
  source = "./modules/monitoring"
  
  name_prefix = local.name_prefix
  common_tags = local.common_tags
  bucket_names = module.storage.bucket_names
  lambda_function_arns = module.lambda.function_arns
  api_gateway_id = module.api_gateway.api_id
  redshift_workgroup_name = module.redshift.workgroup_name
  step_functions_arn = module.eventing.step_functions_arn
  notification_email = var.notification_email
  
  depends_on = [module.storage, module.lambda, module.api_gateway, module.redshift, module.eventing]
}
# 14. Monitoring and Logging
module "monitoring" {
  source = "./modules/monitoring"
  
  name_prefix = local.name_prefix
  common_tags = local.common_tags
  bucket_names = module.storage.bucket_names
  lambda_function_arns = module.lambda.function_arns
  api_gateway_id = module.api_gateway.api_id
  redshift_workgroup_name = module.redshift.workgroup_name
  step_functions_arn = module.eventing.step_functions_arn
  notification_email = var.notification_email
  
  depends_on = [module.storage, module.lambda, module.api_gateway, module.redshift, module.eventing]
}
