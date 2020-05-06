provider "aws" {
  region = "eu-west-2"
}

terraform {
  backend "s3" {
    bucket = "opengp-infra"
    key    = "terraform.tfstate"
    region = "eu-west-2"
  }
}

locals {
  name        = "opengp"
  environment = "demo"

  db_name = "opengp"
  db_user = "admin"

  # This is the convention we use to know what belongs to each other
  ec2_resources_name = "${local.name}-${local.environment}"
}

module "db" {
  source = "./database"
  name = local.db_name
  pass = random_password.db-password.result
  user = local.db_user
  subnet_group_name = module.vpc.database_subnet_group
  security_group = aws_security_group.public_db.id
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.0"

  name = local.name

  cidr = "10.1.0.0/16"

  azs             = ["eu-west-2a", "eu-west-2b"]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24"]
  public_subnets  = ["10.1.11.0/24", "10.1.12.0/24"]
  database_subnets = ["10.1.6.0/24", "10.1.7.0/24"]

  create_database_subnet_group           = true
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway = false # this is faster, but should be "true" for real

  tags = {
    Environment = local.environment
    Name        = local.name
  }
}

resource "aws_ecr_repository" "opengp" {
  name = "opengp"
}

#----- ECS --------
module "ecs" {
  source = "terraform-aws-modules/ecs/aws"
  name   = local.name
}

resource "aws_iam_role" "this" {
  name = "${local.name}_ecs_instance_role"
  path = "/ecs/"

  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ec2.amazonaws.com"]
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "this" {
  name = "${local.name}_ecs_instance_profile"
  role = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_role" {
  role = aws_iam_role.this.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "ecs_ec2_cloudwatch_role" {
  role = aws_iam_role.this.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
#----- ECS  Services--------

module "opengp" {
  source     = "./service"
  cluster_id = module.ecs.this_ecs_cluster_id
  db_name = local.db_name
  db_pass = random_password.db-password.result
  db_user = local.db_user
  db_host = module.db.address
  target_group_arn = module.alb.target_group_arns[0]
  opengp_version = var.opengp_version
}

#----- ECS  Resources--------

#For now we only use the AWS ECS optimized ami <https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html>
data "aws_ami" "amazon_linux_ecs" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

module "this" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"

  name = local.ec2_resources_name

  # Launch configuration
  lc_name = local.ec2_resources_name

  image_id             = data.aws_ami.amazon_linux_ecs.id
  instance_type        = "t2.micro"
  security_groups      = [module.vpc.default_security_group_id, aws_security_group.ec2_instance.id]
  iam_instance_profile = aws_iam_instance_profile.this.id
  user_data            = data.template_file.user_data.rendered

  # Auto scaling group
  asg_name                  = local.ec2_resources_name
  vpc_zone_identifier       = module.vpc.public_subnets
  health_check_type         = "EC2"
  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0

  tags = [
    {
      key                 = "Environment"
      value               = local.environment
      propagate_at_launch = true
    },
    {
      key                 = "Cluster"
      value               = local.name
      propagate_at_launch = true
    },
  ]
}

data "template_file" "user_data" {
  template = file("templates/user-data.sh")

  vars = {
    cluster_name = local.name
  }
}

# ALB
module "alb" {
  source = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"

  name = "opengp"

  load_balancer_type = "application"

  access_logs = {
    bucket = "opengp-load-balancer-logs"
  }

  vpc_id = module.vpc.vpc_id
  subnets = module.vpc.public_subnets
  security_groups = [aws_security_group.public_lb.id]
  target_groups = [
    {
      name = "default"
      backend_protocol = "HTTP"
      backend_port = 80
      health_check = {
        healthy_threshold = 2
        unhealthy_threshold = 7
        path = "/openmrs/"
        matcher = "200,301,302"
      }
    }
  ]

  http_tcp_listeners = [
    {
      port = 80
      protocol = "HTTP"
      target_group_index = 0
    }
  ]


}

resource "aws_security_group" "public_lb" {
  name = "public_lb"
  description = "Allow public traffic to the lb"
  vpc_id = module.vpc.vpc_id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 80
    to_port = 80
    protocol = "tcp"
  }
  egress {
    from_port = 80
    to_port = 80
    security_groups = [module.vpc.default_security_group_id]
    protocol = "tcp"
  }
}

resource "aws_security_group" "public_db" {
  name = "public_db"
  description = "Allow public traffic to the db"
  vpc_id = module.vpc.vpc_id
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
  }
  egress {
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
  }
}

resource "aws_security_group" "ec2_instance" {
  name = "ec2_instance"
  description = "Allow traffic from lb and to outside world to register to ecs"
  vpc_id = module.vpc.vpc_id
  ingress {
    security_groups = [aws_security_group.public_lb.id]
    from_port = 80
    to_port = 80
    protocol = "tcp"
  }
  egress {
    from_port = 0
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
  }
}

resource "random_password" "db-password" {
  length = 16
  special = true
  override_special = "_%@"
}

data "aws_route53_zone" "demo-opengp" {
  name         = "demo.opengp.org"
  private_zone = false
}

resource "aws_route53_record" "demo" {
  zone_id = data.aws_route53_zone.demo-opengp.id
  name    = "demo.opengp.org"
  type    = "A"

  alias {
    name                   = module.alb.this_lb_dns_name
    zone_id                = module.alb.this_lb_zone_id
    evaluate_target_health = true
  }
}