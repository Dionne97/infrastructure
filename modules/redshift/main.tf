# Redshift Serverless

# Redshift Subnet Group
resource "aws_redshift_subnet_group" "main" {
  name       = "${var.name_prefix}-subnet-group"
  subnet_ids = var.private_subnet_ids
  
  tags = var.common_tags
}

# Redshift Serverless Namespace
resource "aws_redshiftserverless_namespace" "main" {
  namespace_name = "${var.name_prefix}-namespace"
  
  admin_username = "admin"
  admin_user_password = random_password.redshift_password.result
  
  db_name = "heal"
  
  default_iam_role_arn = var.redshift_role_arn
  
  iam_roles = [var.redshift_role_arn]
  
  kms_key_id = var.kms_key_arn
  
  tags = var.common_tags
}

# Redshift Serverless Workgroup
resource "aws_redshiftserverless_workgroup" "main" {
  namespace_name = aws_redshiftserverless_namespace.main.namespace_name
  workgroup_name = "${var.name_prefix}-workgroup"
  
  base_capacity = var.base_capacity
  
  subnet_ids = var.private_subnet_ids
  
  security_group_ids = [aws_security_group.redshift.id]
  
  tags = var.common_tags
}

# Security Group for Redshift
resource "aws_security_group" "redshift" {
  name_prefix = "${var.name_prefix}-redshift-"
  vpc_id      = data.aws_vpc.main.id
  
  ingress {
    from_port   = 5439
    to_port     = 5439
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.main.cidr_block]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-redshift-sg"
  })
}

# Random password for Redshift admin
resource "random_password" "redshift_password" {
  length  = 16
  special = true
}

# Secrets Manager secret for Redshift credentials
resource "aws_secretsmanager_secret" "redshift_credentials" {
  name        = "${var.name_prefix}-redshift-credentials"
  description = "Redshift Serverless credentials"
  
  tags = var.common_tags
}

resource "aws_secretsmanager_secret_version" "redshift_credentials" {
  secret_id = aws_secretsmanager_secret.redshift_credentials.id
  secret_string = jsonencode({
    username = aws_redshiftserverless_namespace.main.admin_username
    password = random_password.redshift_password.result
    endpoint = aws_redshiftserverless_workgroup.main.endpoint[0].address
    port     = aws_redshiftserverless_workgroup.main.endpoint[0].port
    database = aws_redshiftserverless_namespace.main.db_name
  })
}

# Data source
data "aws_vpc" "main" {
  id = data.aws_subnet.private[0].vpc_id
}

data "aws_subnet" "private" {
  count = length(var.private_subnet_ids)
  id    = var.private_subnet_ids[count.index]
}
