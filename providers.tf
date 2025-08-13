terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
  }
  backend "s3" {
    # TODO: set your S3 backend (or switch to GCS backend per workspace)
    bucket = "TODO-terraform-state-bucket"
    key    = "multicloud-gitops/terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "TODO-terraform-locks"
  }
}

provider "aws" {
  region = var.aws_region
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

variable "aws_region" { type = string }
variable "gcp_project" { type = string }
variable "gcp_region"  { type = string }
