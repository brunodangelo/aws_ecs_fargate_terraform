resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.ecs_cluster_name
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_cp" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name

  capacity_providers = [var.capacity_provider]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = var.capacity_provider
  }
}

resource "aws_ecs_task_definition" "ecs_td" {
  family = var.task_definition_name
  network_mode = "awsvpc"
  requires_compatibilities = [var.capacity_provider]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn = var.ecs_execution_role_arn
  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = format("%s:%s", var.image_uri, var.image_tag)
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.host_port
        }
      ]
    }
  ])

}

resource "aws_ecs_service" "ecs_service" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_td.arn
  desired_count   = 2
  launch_type     = var.capacity_provider

  load_balancer {
    target_group_arn = aws_lb_target_group.tg_lb.arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  network_configuration {
    security_groups  = [aws_security_group.sg_ecs_tasks.id]
    subnets          = var.public_subnets
    assign_public_ip = "true"
  }

  deployment_controller {
    type = "ECS"
  }
}

#Load Balancer
resource "aws_lb" "lb_app" {
  name               = "lb-app"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [ aws_security_group.sg_lb.id ]
  subnets            = var.public_subnets

  tags = {
    Owner = "Bruno"
  }
}

resource "aws_lb_target_group" "tg_lb" {
  name        = "tg-lb"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    enabled = true
    path     = "/health"
  }
}

resource "aws_lb_listener" "listener_lb" { 
  load_balancer_arn = aws_lb.lb_app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_lb.arn
  }
}

#Security Groups
resource "aws_security_group" "sg_lb" {
  name        = "SG Load Balancer"
  description = "Security group del Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    protocol = "tcp"
    to_port = 80
    from_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol = "-1"
    to_port = 0
    from_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Owner = "Bruno"
  }
}

resource "aws_security_group" "sg_ecs_tasks" {
  name        = "SG_ecs_tasks"
  description = "Security group de las tareas de ECS"
  vpc_id      = var.vpc_id

  ingress {
    protocol = "tcp"
    to_port = var.container_port
    from_port = var.container_port
    security_groups = [aws_security_group.sg_lb.id]
  }

  egress {
    protocol = "-1"
    to_port = 0
    from_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Owner = "Bruno"
  }
}

#Auto Escalado
resource "aws_appautoscaling_target" "ecs_target" {
  max_capacity       = 4
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_down_policy" {
  name               = "scale-down"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.ecs_target]
}

resource "aws_appautoscaling_policy" "ecs_up_policy" {
  name               = "scale-up"
  policy_type        = "StepScaling"
  resource_id        = aws_appautoscaling_target.ecs_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_target.service_namespace

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.ecs_target]

}

resource "aws_cloudwatch_metric_alarm" "service_cpu_high" {
  alarm_name          = "cb_cpu_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "85"

  dimensions = {
    ClusterName = aws_ecs_cluster.ecs_cluster.name
    ServiceName = aws_ecs_service.ecs_service.name
  }

  alarm_actions = [aws_appautoscaling_policy.ecs_up_policy.arn]
}

resource "aws_cloudwatch_metric_alarm" "service_cpu_low" {
  alarm_name          = "cb_cpu_utilization_low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "15"

  dimensions = {
    ClusterName = aws_ecs_cluster.ecs_cluster.name
    ServiceName = aws_ecs_service.ecs_service.name
  }

  alarm_actions = [aws_appautoscaling_policy.ecs_down_policy.arn]
}