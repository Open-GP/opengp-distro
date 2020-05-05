variable "name" {
  description = "The name of the database"
  type        = string
}

variable "user" {
  description = "User for the database"
  type        = string
}

variable "pass" {
  description = "Password to access database"
  type        = string
}

variable "subnet_group_name" {
  description = "Subnet to attach the database to"
  type = string
}

variable "security_group" {
  description = "Security group"
  type = string
}