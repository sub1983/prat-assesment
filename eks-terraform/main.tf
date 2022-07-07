provider "aws" {
  region  = var.region
  profile = "default"
}

terraform {
  backend "s3" {
    bucket         = "eks-terraform-subin-s3-13377"
    key            = "eks-terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "eks-terraform-state"
  }
}

locals {
  vpc-name     = "${var.project}-VPC-${var.environment}"
  environment  = var.environment
  region       = var.region
  cluster_name = "${var.project}-EKS-${var.environment}"
}

resource "aws_eip" "nat" {
  count = 2

  vpc = true
}

resource "aws_eip" "nlb" {
  count = 0

  vpc = true
}


module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name = local.vpc-name
  cidr = "10.100.0.0/16"

  azs             = ["${local.region}a", "${local.region}b"]
  public_subnets  = ["10.100.0.0/19", "10.100.32.0/19"]
  private_subnets = ["10.100.64.0/19", "10.100.96.0/19"]

  public_subnet_tags = {
    Name                                          = "PUBLIC-SUBNET-${var.project}-${local.environment}"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }
  private_subnet_tags = {
    Name                                          = "PRIVATE-SUBNET-${var.project}-${local.environment}"
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }

  manage_default_route_table   = true
  default_route_table_tags     = { DefaultRouteTable = true }
  create_database_subnet_group = true
  enable_dns_hostnames         = true
  enable_dns_support           = true
  enable_nat_gateway           = true
  single_nat_gateway           = false
  reuse_nat_ips                = true
  external_nat_ip_ids          = aws_eip.nat.*.id

  # Default security group - ingress/egress rules cleared to deny all
  manage_default_security_group  = true
  default_security_group_ingress = []
  default_security_group_egress  = []
}

##########
#Data
##########

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}


data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}


provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "aws_availability_zones" "available" {
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = var.eksversion
  subnet_ids      = module.vpc.private_subnets

  tags = {
    Name        = "${var.project}-EKS-${local.environment}-CLUSTER"
    Environment = "${local.environment}"
  }

  vpc_id = module.vpc.vpc_id

  eks_managed_node_group_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 35
  }

  eks_managed_node_groups = {
    SPOT-WORKER-NODE = {
      desired_capacity = 1
      max_capacity     = 1
      min_capacity     = 1

      instance_types = ["t3.small"]
      capacity_type  = "SPOT"
      k8s_labels = {
        Environment = "${local.environment}"
      }
      additional_tags = {
        SPOT = "TRUE"
      }

    },
    ON-DEMAND = {
      desired_capacity = 1
      max_capacity     = 1
      min_capacity     = 1

      instance_types = ["t3a.small"]
      capacity_type  = "ON_DEMAND"
      k8s_labels = {
        Environment = "test"
      }
      additional_tags = {
        ON-DEMAND = "true"
      }

    }
  }
}

















