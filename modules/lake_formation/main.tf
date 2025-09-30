# Lake Formation for fine-grained permissions

# Lake Formation Data Lake Settings
resource "aws_lakeformation_data_lake_settings" "main" {
  admins = [data.aws_caller_identity.current.arn]
  
  create_database_default_permissions {
    permissions = ["ALL"]
    principal   = data.aws_caller_identity.current.arn
  }
  
  create_table_default_permissions {
    permissions = ["ALL"]
    principal   = data.aws_caller_identity.current.arn
  }
}

# Lake Formation Resource
resource "aws_lakeformation_resource" "raw_data" {
  arn = "arn:aws:s3:::${var.bucket_names.raw_data}"
}

resource "aws_lakeformation_resource" "curated_data" {
  arn = "arn:aws:s3:::${var.bucket_names.curated_data}"
}

resource "aws_lakeformation_resource" "features_data" {
  arn = "arn:aws:s3:::${var.bucket_names.features_data}"
}

# Lake Formation Permissions
resource "aws_lakeformation_permissions" "glue_raw_data" {
  principal   = var.glue_role_arn
  permissions = ["DATA_LOCATION_ACCESS"]
  
  data_location {
    arn = aws_lakeformation_resource.raw_data.arn
  }
}

resource "aws_lakeformation_permissions" "glue_curated_data" {
  principal   = var.glue_role_arn
  permissions = ["DATA_LOCATION_ACCESS"]
  
  data_location {
    arn = aws_lakeformation_resource.curated_data.arn
  }
}

resource "aws_lakeformation_permissions" "glue_features_data" {
  principal   = var.glue_role_arn
  permissions = ["DATA_LOCATION_ACCESS"]
  
  data_location {
    arn = aws_lakeformation_resource.features_data.arn
  }
}

# Lake Formation Database Permissions
resource "aws_lakeformation_permissions" "glue_database_raw" {
  principal   = var.glue_role_arn
  permissions = ["CREATE_TABLE", "ALTER", "DROP"]
  
  database {
    name = "${var.name_prefix}_raw"
  }
}

resource "aws_lakeformation_permissions" "glue_database_curated" {
  principal   = var.glue_role_arn
  permissions = ["CREATE_TABLE", "ALTER", "DROP"]
  
  database {
    name = "${var.name_prefix}_curated"
  }
}

resource "aws_lakeformation_permissions" "glue_database_features" {
  principal   = var.glue_role_arn
  permissions = ["CREATE_TABLE", "ALTER", "DROP"]
  
  database {
    name = "${var.name_prefix}_features"
  }
}

# Data source
data "aws_caller_identity" "current" {}
