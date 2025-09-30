# KMS Customer Managed Keys for different data domains

# S3 Data Encryption Key
resource "aws_kms_key" "s3_data" {
  description             = "KMS key for S3 data encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-s3-data-key"
    Type = "S3Data"
  })
}

resource "aws_kms_alias" "s3_data" {
  name          = "alias/${var.name_prefix}-s3-data"
  target_key_id = aws_kms_key.s3_data.key_id
}

# Redshift Encryption Key
resource "aws_kms_key" "redshift" {
  description             = "KMS key for Redshift encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-redshift-key"
    Type = "Redshift"
  })
}

resource "aws_kms_alias" "redshift" {
  name          = "alias/${var.name_prefix}-redshift"
  target_key_id = aws_kms_key.redshift.key_id
}

# Glue Encryption Key
resource "aws_kms_key" "glue" {
  description             = "KMS key for Glue encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-glue-key"
    Type = "Glue"
  })
}

resource "aws_kms_alias" "glue" {
  name          = "alias/${var.name_prefix}-glue"
  target_key_id = aws_kms_key.glue.key_id
}

# Logs Encryption Key
resource "aws_kms_key" "logs" {
  description             = "KMS key for logs encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-logs-key"
    Type = "Logs"
  })
}

resource "aws_kms_alias" "logs" {
  name          = "alias/${var.name_prefix}-logs"
  target_key_id = aws_kms_key.logs.key_id
}

# Secrets Manager Encryption Key
resource "aws_kms_key" "secrets" {
  description             = "KMS key for Secrets Manager encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-secrets-key"
    Type = "Secrets"
  })
}

resource "aws_kms_alias" "secrets" {
  name          = "alias/${var.name_prefix}-secrets"
  target_key_id = aws_kms_key.secrets.key_id
}
