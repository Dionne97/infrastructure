# QuickSight for BI and embedding

# QuickSight Data Source
resource "aws_quicksight_data_source" "redshift" {
  data_source_id = "${var.name_prefix}-redshift-datasource"
  name          = "${var.name_prefix} Redshift Data Source"
  type          = "REDSHIFT"
  
  parameters {
    redshift {
      cluster_id = var.redshift_endpoint
      database   = "heal"
      host       = var.redshift_endpoint
      port       = 5439
    }
  }
  
  credentials {
    credential_pair {
      username = "admin"
      password = "placeholder" # This should be retrieved from Secrets Manager
    }
  }
  
  tags = var.common_tags
}

# QuickSight Dataset
resource "aws_quicksight_data_set" "harmonized_data" {
  data_set_id = "${var.name_prefix}-harmonized-dataset"
  name        = "${var.name_prefix} Harmonized Data"
  
  physical_table_map {
    physical_table_map_id = "harmonized_data"
    
    redshift {
      data_source_physical_table_id = aws_quicksight_data_source.redshift.data_source_id
      
      input_columns {
        name = "id"
        type = "STRING"
      }
      
      input_columns {
        name = "facility_id"
        type = "STRING"
      }
      
      input_columns {
        name = "indicator_id"
        type = "STRING"
      }
      
      input_columns {
        name = "value"
        type = "DECIMAL"
      }
      
      input_columns {
        name = "period"
        type = "STRING"
      }
      
      input_columns {
        name = "created_at"
        type = "DATETIME"
      }
    }
  }
  
  tags = var.common_tags
}

# QuickSight Analysis
resource "aws_quicksight_analysis" "main" {
  analysis_id = "${var.name_prefix}-analysis"
  name        = "${var.name_prefix} Analysis"
  
  definition {
    data_set_identifier_declarations {
      data_set_arn = aws_quicksight_data_set.harmonized_data.arn
      data_set_identifier = "harmonized_data"
    }
    
    sheets {
      sheet_id = "main_sheet"
      name     = "Main Dashboard"
      
      visuals {
        visual_id = "chart_1"
        line_chart_visual {
          visual_id = "chart_1"
          title {
            visibility = "VISIBLE"
            format_text {
              plain_text = "Health Indicators Over Time"
            }
          }
          
          chart_configuration {
            field_wells {
              line_chart_aggregated_field_wells {
                category {
                  categorical_dimension_field {
                    field_id = "period"
                    column {
                      data_set_identifier = "harmonized_data"
                      column_name = "period"
                    }
                  }
                }
                
                values {
                  numerical_measure_field {
                    field_id = "value"
                    column {
                      data_set_identifier = "harmonized_data"
                      column_name = "value"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  
  tags = var.common_tags
}

# QuickSight Dashboard
resource "aws_quicksight_dashboard" "main" {
  dashboard_id = "${var.name_prefix}-dashboard"
  name         = "${var.name_prefix} Dashboard"
  
  definition {
    data_set_identifier_declarations {
      data_set_arn = aws_quicksight_data_set.harmonized_data.arn
      data_set_identifier = "harmonized_data"
    }
    
    sheets {
      sheet_id = "main_sheet"
      name     = "Main Dashboard"
      
      visuals {
        visual_id = "chart_1"
        line_chart_visual {
          visual_id = "chart_1"
          title {
            visibility = "VISIBLE"
            format_text {
              plain_text = "Health Indicators Over Time"
            }
          }
          
          chart_configuration {
            field_wells {
              line_chart_aggregated_field_wells {
                category {
                  categorical_dimension_field {
                    field_id = "period"
                    column {
                      data_set_identifier = "harmonized_data"
                      column_name = "period"
                    }
                  }
                }
                
                values {
                  numerical_measure_field {
                    field_id = "value"
                    column {
                      data_set_identifier = "harmonized_data"
                      column_name = "value"
                    }
                    aggregation_function {
                      simple_numerical_aggregation = "SUM"
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  
  tags = var.common_tags
}

# QuickSight User (for embedding)
resource "aws_quicksight_user" "embed_user" {
  user_name     = "${var.name_prefix}-embed-user"
  email         = "embed@${var.name_prefix}.com"
  identity_type = "QUICKSIGHT"
  user_role     = "READER"
  
  tags = var.common_tags
}
