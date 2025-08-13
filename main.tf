terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = { Name = "${var.cluster_name}-vpc" }
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = { Name = "${var.cluster_name}-public-${count.index}" }
}

data "aws_availability_zones" "available" {}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 20.8"
  cluster_name    = var.cluster_name
  cluster_version = "1.29"
  subnet_ids      = aws_subnet.public[*].id
  vpc_id          = aws_vpc.this.id

  eks_managed_node_groups = {
    default = {
      instance_types = var.node_instance_types
      desired_size   = var.desired_size
      max_size       = var.max_size
      min_size       = var.min_size
    }
  }
}

output "cluster_name" { value = module.eks.cluster_name }
output "cluster_endpoint" { value = module.eks.cluster_endpoint }
output "cluster_ca" { value = module.eks.cluster_certificate_authority_data }
output "kubeconfig" {
  value = jsonencode({
    apiVersion: "v1",
    clusters: [{
      cluster: {
        server: module.eks.cluster_endpoint,
        certificate-authority-data: module.eks.cluster_certificate_authority_data
      },
      name: module.eks.cluster_name
    }],
    contexts: [{
      context: {
        cluster: module.eks.cluster_name,
        user: module.eks.cluster_name
      },
      name: module.eks.cluster_name
    }],
    current-context: module.eks.cluster_name,
    kind: "Config",
    users: [{
      name: module.eks.cluster_name,
      user: { exec: {
        apiVersion: "client.authentication.k8s.io/v1beta1",
        command: "aws",
        args: ["eks","get-token","--cluster-name", module.eks.cluster_name]
      }}
    }]
  })
  sensitive = true
}
