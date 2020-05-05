resource "aws_db_instance" "default" {
  allocated_storage = 20
  storage_type = "gp2"
  engine = "mysql"
  engine_version = "5.7"
  instance_class = "db.t2.micro"
  name = var.name
  username = var.user
  password = var.pass
  parameter_group_name = "rds-pg"
  publicly_accessible = true
  skip_final_snapshot = true

  availability_zone = "eu-west-2a"

  db_subnet_group_name = var.subnet_group_name
  apply_immediately = true

  vpc_security_group_ids = [var.security_group]

}

resource "aws_db_parameter_group" "default_pg" {
  name   = "rds-pg"
  family = "mysql5.7"

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  parameter {
    name  = "collation_server"
    value = "utf8_general_ci"
  }
}