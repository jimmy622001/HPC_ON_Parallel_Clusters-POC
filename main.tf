terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

# Create VPC
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
  project_name         = var.project_name
  environment          = var.environment
}

# Create EFS for home directories
module "efs" {
  source = "./modules/efs"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  security_groups    = [module.vpc.efs_security_group_id]
  project_name       = var.project_name
  environment        = var.environment

  depends_on = [module.vpc]
}

# Create RDS Aurora MySQL for Slurm Accounting
module "rds" {
  source = "./modules/rds"

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  security_groups    = [module.vpc.rds_security_group_id]
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
  instance_class     = var.environment == "prod" ? "db.r5.large" : "db.t3.medium"
  project_name       = var.project_name
  environment        = var.environment

  depends_on = [module.vpc]
}

# Create Open OnDemand EC2 instances
module "ondemand" {
  source = "./modules/ondemand"

  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  security_groups    = [module.vpc.ondemand_security_group_id]
  key_name           = var.key_name
  instance_type      = var.ondemand_instance_type
  efs_id             = module.efs.efs_id
  db_endpoint        = module.rds.cluster_endpoint # Using the direct cluster endpoint
  db_username        = var.db_username
  db_password        = var.db_password
  domain_name        = var.domain_name
  project_name       = var.project_name
  environment        = var.environment

  depends_on = [
    module.vpc,
    module.efs,
    module.rds # Ensure RDS is created first
  ]
}

# Create Application Load Balancer
module "alb" {
  source = "./modules/alb"

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  security_groups   = [module.vpc.alb_security_group_id]
  target_group_arn  = module.ondemand.target_group_arn
  domain_name       = var.domain_name
  zone_id           = var.zone_id
  project_name      = var.project_name
  environment       = var.environment

  depends_on = [
    module.vpc,
    module.ondemand
  ]
}
