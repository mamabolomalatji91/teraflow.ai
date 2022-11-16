##Provider
	terraform {
	  required_providers {
	    aws = {
	      source  = "hashicorp/aws"
	      version = "~> 4.0"
	    }
	  }
	}
	

	# Configure the AWS Provider
	provider "aws" {
	  region = "af-south-1"
	}
	

	###############
	variable "bucket-name" {
	  default = "mybucket-lake-capetown2"
	}
	

	variable "arn-var" {
	  default = "arn:aws:iam::618249149314:group"
	}
	###############
	

	##create S3
	resource "aws_s3_bucket" "create-s3-bucket" {
	  bucket = "${var.bucket-name}"
	  acl="private"
	  lifecycle_rule {
	    id="archive"
	    enabled = true
	    transition {
	      days=30
	      storage_class = "STANDARD_IA"
	    }
	    transition {
	      days = 60
	      storage_class = "GLACIER"
	    }
	  }
	  versioning { enabled = true}
	  tags = {
	    Environment: "Dev"
	  }
	}
	

	

	##Budget:
	resource "aws_budgets_budget" "monthly-budget" {
	  name              = "monthly-budget"
	  budget_type       = "COST"
	  limit_amount      = "1"
	  limit_unit        = "USD"
	  time_period_start = "2022-11-14_00:00"
	  time_unit         = "MONTHLY"
	  }
	



	 variable "file-name" {
	   default = "etl.py"
	 }
	

	 resource "aws_s3_bucket_object" "object" {
	   bucket = "${var.bucket-name}"
	   key    = "Script/Glue/${var.file-name}"
	  

	 }
	

	  ##################
	  # Glue Catalog   #
	  ##################
	  resource "aws_glue_catalog_table" "aws_glue_catalog_table" {
	    name          = "MyCatalogTable"
	    database_name = "MyCatalogDatabase"
	  }
	

	

	

	  ##################
	  # Glue Crawler   #
	  ##################
	  resource "aws_glue_crawler" "example" {
	    database_name = aws_glue_catalog_database.example.name
	    name          = "teraflow-crawler"
	    role          = "${var.arn-var}"
	

	    catalog_target {
	      database_name = MyCatalogDatabase.example.name
	

	    }
	

	    schema_change_policy {
	      delete_behavior = "LOG"
	    }
	

	    configuration = <<EOF
	  {
	    "Version":1.0,
	    "Grouping": {
	      "TableGroupingPolicy": "CombineCompatibleSchemas"
	    }
	  }
	  EOF

