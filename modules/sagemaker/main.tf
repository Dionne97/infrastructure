# SageMaker for ML workloads

# SageMaker Notebook Instance
resource "aws_sagemaker_notebook_instance" "main" {
  name          = "${var.name_prefix}-notebook"
  instance_type = "ml.t3.medium"
  role_arn      = var.sagemaker_role_arn
  
  lifecycle_config_name = aws_sagemaker_notebook_instance_lifecycle_configuration.main.name
  
  tags = var.common_tags
}

# SageMaker Notebook Instance Lifecycle Configuration
resource "aws_sagemaker_notebook_instance_lifecycle_configuration" "main" {
  name = "${var.name_prefix}-notebook-lifecycle"
  
  on_create = base64encode(<<EOF
#!/bin/bash
pip install --upgrade pip
pip install pandas numpy scikit-learn matplotlib seaborn boto3
EOF
  )
  
  on_start = base64encode(<<EOF
#!/bin/bash
echo "Starting notebook instance..."
EOF
  )
}

# SageMaker Model Package Group
resource "aws_sagemaker_model_package_group" "main" {
  model_package_group_name = "${var.name_prefix}-model-package-group"
  model_package_group_description = "HEAL MVP Model Package Group"
  
  tags = var.common_tags
}

# SageMaker Processing Job (placeholder)
resource "aws_sagemaker_processing_job" "feature_engineering" {
  name         = "${var.name_prefix}-feature-engineering"
  role_arn     = var.sagemaker_role_arn
  
  processing_resources {
    cluster_config {
      instance_count  = 1
      instance_type   = "ml.m5.large"
      volume_size_in_gb = 30
    }
  }
  
  app_specification {
    image_uri = "683313688378.dkr.ecr.us-west-2.amazonaws.com/sagemaker-scikit-learn:0.23-1-cpu-py3"
    
    container_arguments = [
      "--input-data", "s3://${var.bucket_names.curated_data}/",
      "--output-data", "s3://${var.bucket_names.features_data}/",
      "--job-name", "${var.name_prefix}-feature-engineering"
    ]
  }
  
  tags = var.common_tags
}

# SageMaker Training Job (placeholder)
resource "aws_sagemaker_training_job" "model_training" {
  name     = "${var.name_prefix}-model-training"
  role_arn = var.sagemaker_role_arn
  
  algorithm_specification {
    training_image = "683313688378.dkr.ecr.us-west-2.amazonaws.com/sagemaker-scikit-learn:0.23-1-cpu-py3"
    training_input_mode = "File"
  }
  
  input_data_config {
    channel_name = "training"
    data_source {
      s3_data_source {
        s3_data_type = "S3Prefix"
        s3_uri       = "s3://${var.bucket_names.features_data}/training/"
      }
    }
  }
  
  output_data_config {
    s3_output_path = "s3://${var.bucket_names.features_data}/models/"
  }
  
  resource_config {
    instance_count = 1
    instance_type  = "ml.m5.large"
    volume_size_in_gb = 30
  }
  
  stopping_condition {
    max_runtime_in_seconds = 3600
  }
  
  tags = var.common_tags
}

# SageMaker Model (placeholder)
resource "aws_sagemaker_model" "main" {
  name               = "${var.name_prefix}-model"
  execution_role_arn = var.sagemaker_role_arn
  
  primary_container {
    image = "683313688378.dkr.ecr.us-west-2.amazonaws.com/sagemaker-scikit-learn:0.23-1-cpu-py3"
    
    model_data_url = "s3://${var.bucket_names.features_data}/models/model.tar.gz"
    
    environment = {
      SAGEMAKER_PROGRAM = "inference.py"
      SAGEMAKER_SUBMIT_DIRECTORY = "s3://${var.bucket_names.features_data}/models/model.tar.gz"
    }
  }
  
  tags = var.common_tags
}

# SageMaker Endpoint Configuration (placeholder)
resource "aws_sagemaker_endpoint_configuration" "main" {
  name = "${var.name_prefix}-endpoint-config"
  
  production_variants {
    variant_name           = "primary"
    model_name            = aws_sagemaker_model.main.name
    initial_instance_count = 1
    instance_type         = "ml.t2.medium"
    initial_variant_weight = 100
  }
  
  tags = var.common_tags
}

# SageMaker Endpoint (placeholder)
resource "aws_sagemaker_endpoint" "main" {
  name                 = "${var.name_prefix}-endpoint"
  endpoint_config_name = aws_sagemaker_endpoint_configuration.main.name
  
  tags = var.common_tags
}
