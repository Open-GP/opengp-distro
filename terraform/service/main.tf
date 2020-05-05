resource "aws_ecs_task_definition" "opengp" {
  family = "opengp"

  container_definitions = data.template_file.task_definition.rendered
}

data "template_file" "task_definition" {
  template = file("task-definitions/service.json")

  vars = {
    db_host = var.db_host
    db_user = var.db_user
    db_pass = var.db_pass
    db_name = var.db_name
  }
}

resource "aws_ecs_service" "opengp" {
  name = "opengp"
  cluster = var.cluster_id
  task_definition = aws_ecs_task_definition.opengp.arn

  desired_count = 1

  deployment_maximum_percent = 100
  deployment_minimum_healthy_percent = 0

    load_balancer {
      target_group_arn = var.target_group_arn
      container_name = "opengp"
      container_port = 8080
    }

}