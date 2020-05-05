variable "cluster_id" {
  description = "The ECS cluster ID"
  type        = string
}

variable "db_host" {
  description = "Database hostname"
  type        = string
}

variable "db_name" {
  description = "The name of the database"
  type        = string
}

variable "db_user" {
  description = "User for the database"
  type        = string
}

variable "db_pass" {
  description = "Password to access database"
  type        = string
}


variable "target_group_arn" {
  description = "Target group"
  type = string
}