resource "aws_ecr_repository" "nodejs_app_repo" {
  name                 = "nodejs_app_repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_cluster" "nodejs_app_cluster" {
  name = "nodejs-app-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_service" "nodejs_service" {
  name            = "nodejs-service"
  cluster         = aws_ecs_cluster.nodejs_app_cluster.id
  task_definition = aws_ecs_task_definition.nodejs_task.arn
  desired_count   = 1
  iam_role        = aws_iam_role.ecs_service_role.arn
  depends_on      = [aws_iam_role_policy.ecs_policy, aws_ecs_task_definition.nodejs_task]

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_target.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  # placement_constraints {
  #   type       = "memberOf"
  #   expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  # }
}

resource "aws_ecs_task_definition" "nodejs_task" {
  family = "service"
  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = "${var.ACCOUNT_ID}.dkr.ecr.${var.aws_region}.amazonaws.com/${aws_ecr_repository.nodejs_app_repo.name}:latest"
      cpu       = 10
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = 0
        }
      ]
    },
  ])

  volume {
    name      = "service-storage"
    host_path = "/ecs/service-storage"
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  }
}


resource "aws_launch_configuration" "ecs_launch_config" {
  image_id             = var.ecs_image_ami
  iam_instance_profile = aws_iam_instance_profile.ecs_agent.name
  security_groups      = [aws_security_group.allow_ecs.id]
  user_data            = "#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.nodejs_app_cluster.name} >> /etc/ecs/ecs.config"
  instance_type        = "t2.medium"
  # auto assign public IP
}

resource "aws_autoscaling_group" "ecs_auto_scaling_group" {
  name                 = "asg"
  vpc_zone_identifier  = [aws_subnet.public_subnet[0].id]
  launch_configuration = aws_launch_configuration.ecs_launch_config.name

  desired_capacity          = 1
  min_size                  = 1
  max_size                  = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
}