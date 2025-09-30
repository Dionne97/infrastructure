# Glue Data Catalog and Jobs

# Glue Databases
resource "aws_glue_catalog_database" "raw" {
  name        = "${var.name_prefix}_raw"
  description = "Raw data database"
  
  tags = var.common_tags
}

resource "aws_glue_catalog_database" "curated" {
  name        = "${var.name_prefix}_curated"
  description = "Curated data database"
  
  tags = var.common_tags
}

resource "aws_glue_catalog_database" "features" {
  name        = "${var.name_prefix}_features"
  description = "Features data database"
  
  tags = var.common_tags
}

# Glue Crawlers
resource "aws_glue_crawler" "raw_data" {
  database_name = aws_glue_catalog_database.raw.name
  name          = "${var.name_prefix}-raw-crawler"
  role          = var.glue_role_arn
  
  s3_target {
    path = "s3://${var.bucket_names.raw_data}/"
  }
  
  tags = var.common_tags
}

resource "aws_glue_crawler" "curated_data" {
  database_name = aws_glue_catalog_database.curated.name
  name          = "${var.name_prefix}-curated-crawler"
  role          = var.glue_role_arn
  
  s3_target {
    path = "s3://${var.bucket_names.curated_data}/"
  }
  
  tags = var.common_tags
}

resource "aws_glue_crawler" "features_data" {
  database_name = aws_glue_catalog_database.features.name
  name          = "${var.name_prefix}-features-crawler"
  role          = var.glue_role_arn
  
  s3_target {
    path = "s3://${var.bucket_names.features_data}/"
  }
  
  tags = var.common_tags
}

# Glue Jobs (placeholders)
resource "aws_glue_job" "harmonize_data" {
  name         = "${var.name_prefix}-harmonize-job"
  role_arn     = var.glue_role_arn
  glue_version = "4.0"
  
  command {
    script_location = "s3://${var.bucket_names.raw_data}/scripts/harmonize_data.py"
    python_version  = "3"
  }
  
  default_arguments = {
    "--job-language"                    = "python"
    "--job-bookmark-option"            = "job-bookmark-enable"
    "--enable-metrics"                 = ""
    "--enable-continuous-cloudwatch-log" = "true"
    "--TempDir"                        = "s3://${var.bucket_names.raw_data}/temp/"
    "--job-bookmark-option"            = "job-bookmark-enable"
    "--enable-metrics"                 = ""
    "--enable-continuous-cloudwatch-log" = "true"
  }
  
  tags = var.common_tags
}

resource "aws_glue_job" "mfr_joins" {
  name         = "${var.name_prefix}-mfr-joins-job"
  role_arn     = var.glue_role_arn
  glue_version = "4.0"
  
  command {
    script_location = "s3://${var.bucket_names.raw_data}/scripts/mfr_joins.py"
    python_version  = "3"
  }
  
  default_arguments = {
    "--job-language"                    = "python"
    "--job-bookmark-option"            = "job-bookmark-enable"
    "--enable-metrics"                 = ""
    "--enable-continuous-cloudwatch-log" = "true"
    "--TempDir"                        = "s3://${var.bucket_names.raw_data}/temp/"
    "--job-bookmark-option"            = "job-bookmark-enable"
    "--enable-metrics"                 = ""
    "--enable-continuous-cloudwatch-log" = "true"
  }
  
  tags = var.common_tags
}

# Glue Connection (for external data sources if needed)
resource "aws_glue_connection" "dhis2" {
  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:postgresql://dhis2.example.com:5432/dhis2"
    USERNAME            = "dhis2_user"
    PASSWORD            = "dhis2_password"
  }
  
  name = "${var.name_prefix}-dhis2-connection"
  
  physical_connection_requirements {
    availability_zone      = data.aws_availability_zones.available.names[0]
    security_group_id_list = [data.aws_security_group.default.id]
    subnet_id              = data.aws_subnet.private[0].id
  }
  
  tags = var.common_tags
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.main.id
}

data "aws_vpc" "main" {
  default = true
}

data "aws_subnet" "private" {
  count = 1
  vpc_id = data.aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
}
