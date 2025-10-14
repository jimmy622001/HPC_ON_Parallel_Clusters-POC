# IAM Role for EC2 Instances
resource "aws_iam_role" "ondemand" {
  name = "${var.project_name}-${var.environment}-ondemand-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-ondemand-role"
    Environment = var.environment
    Project     = var.project_name
  }
}

# IAM Role Policy
resource "aws_iam_role_policy_attachment" "ondemand" {
  role       = aws_iam_role.ondemand.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ondemand" {
  name = "${var.project_name}-${var.environment}-ondemand-profile"
  role = aws_iam_role.ondemand.name
}

# Launch Template for OnDemand Instances
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

resource "aws_launch_template" "ondemand" {
  name          = "${var.project_name}-${var.environment}-launch-template"
  image_id      = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  key_name      = var.key_name
  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    efs_id      = var.efs_id
    db_endpoint = var.db_endpoint
    db_name     = var.db_name
    db_username = var.db_username
    db_password = var.db_password
    ood_version = var.ood_version
    domain_name = var.domain_name
  }))

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = var.security_groups
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ondemand.name
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project_name}-${var.environment}-ondemand"
      Environment = var.environment
      Project     = var.project_name
    }
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-launch-template"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "ondemand" {
  name                = "${var.project_name}-${var.environment}-asg"
  vpc_zone_identifier = var.private_subnet_ids
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size

  launch_template {
    id      = aws_launch_template.ondemand.id
    version = "$Latest"
  }

  target_group_arns = [aws_lb_target_group.ondemand.arn]

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-ondemand"
    propagate_at_launch = true
  }

  tag {
    key                 = "Environment"
    value               = var.environment
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = var.project_name
    propagate_at_launch = true
  }
}

# Application Load Balancer Target Group
resource "aws_lb_target_group" "ondemand" {
  name        = "${var.project_name}-${var.environment}-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled             = true
    interval            = 30
    path                = "/nagios_health"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    protocol            = "HTTP"
    matcher             = "200-399"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-tg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Outputs
output "asg_name" {
  value = aws_autoscaling_group.ondemand.name
}

output "target_group_arn" {
  value = aws_lb_target_group.ondemand.arn
}

output "instance_ids" {
  value = []
  # Note: To get instance IDs, you'll need to use the AWS CLI or AWS Console
  # as the instances are managed by the Auto Scaling Group
  # You can also use the aws_instances data source in the root module if needed
}
