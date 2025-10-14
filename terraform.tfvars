# AWS Region
aws_region = "eu-west-1"

# Network Configuration
vpc_cidr             = "10.1.0.0/16"
public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
private_subnet_cidrs = ["10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24"]
availability_zones   = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

# Database Configuration
db_name     = "ood_db"
db_username = "ood_admin"
db_password = "ChangeThisPassword123!" # Change this in production

# Instance Configuration
key_name               = "your-key-pair" # Replace with your EC2 key pair name
ondemand_instance_type = "t3.medium"     # Good balance of cost and performance

# Domain Configuration (optional)
domain_name = "onaws-mkai.online" # Replace with your domain
zone_id     = "YOUR_ZONE_ID"      # Replace with your Route53 zone ID

# Project Configuration
project_name = "open-ondemand"
environment  = "dev"

# Instance Counts (for scaling)
desired_capacity = 1
min_size         = 1
max_size         = 3