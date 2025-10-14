resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "${var.project_name}-${var.environment}-db-subnet-group"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_rds_cluster" "main" {
  cluster_identifier = "${var.project_name}-${var.environment}-cluster"
  engine             = "aurora-mysql"
  engine_version     = "5.7.mysql_aurora.2.11.2"
  database_name      = var.db_name
  master_username    = var.db_username
  master_password    = var.db_password

  vpc_security_group_ids = var.security_groups
  db_subnet_group_name   = aws_db_subnet_group.main.name

  skip_final_snapshot       = var.environment == "prod" ? false : true
  apply_immediately         = true
  deletion_protection       = var.environment == "prod"
  final_snapshot_identifier = var.environment == "prod" ? "${var.project_name}-${var.environment}-final-snapshot" : null

  backup_retention_period      = var.environment == "prod" ? 7 : 1
  preferred_backup_window      = "07:00-09:00"
  preferred_maintenance_window = "sun:09:00-sun:11:00"

  enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]

  tags = {
    Name        = "${var.project_name}-${var.environment}-cluster"
    Environment = var.environment
    Project     = var.project_name
  }

  lifecycle {
    ignore_changes = [
      master_password,
      engine_version
    ]
  }
}

resource "aws_rds_cluster_instance" "main" {
  count                = var.environment == "prod" ? 2 : 1
  identifier           = "${var.project_name}-${var.environment}-instance-${count.index + 1}"
  cluster_identifier   = aws_rds_cluster.main.id
  instance_class       = var.instance_class
  engine               = aws_rds_cluster.main.engine
  engine_version       = aws_rds_cluster.main.engine_version
  db_subnet_group_name = aws_db_subnet_group.main.name

  performance_insights_enabled = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-instance-${count.index + 1}"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Outputs
output "rds_cluster_id" {
  value = aws_rds_cluster.main.id
}

output "rds_cluster_endpoint" {
  value = aws_rds_cluster.main.endpoint
}

output "rds_cluster_reader_endpoint" {
  value = aws_rds_cluster.main.reader_endpoint
}

output "rds_cluster_port" {
  value = aws_rds_cluster.main.port
}

output "rds_cluster_database_name" {
  value = aws_rds_cluster.main.database_name
}

output "rds_cluster_master_username" {
  value     = aws_rds_cluster.main.master_username
  sensitive = true
}
