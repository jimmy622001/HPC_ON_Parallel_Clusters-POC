resource "aws_efs_file_system" "main" {
  creation_token = "${var.project_name}-${var.environment}-efs"

  tags = {
    Name        = "${var.project_name}-${var.environment}-efs"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_efs_mount_target" "main" {
  count           = length(var.private_subnet_ids)
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = var.security_groups
}

resource "aws_efs_access_point" "home" {
  file_system_id = aws_efs_file_system.main.id

  root_directory {
    path = "/home"
    creation_info {
      owner_uid   = 1000
      owner_gid   = 1000
      permissions = "0755"
    }
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-home"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Outputs
output "efs_id" {
  value = aws_efs_file_system.main.id
}

output "efs_dns_name" {
  value = aws_efs_file_system.main.dns_name
}

output "efs_arn" {
  value = aws_efs_file_system.main.arn
}

output "efs_access_point_id" {
  value = aws_efs_access_point.home.id
}
