
variable "region" {
  type = string
}
variable "ami_id" {
  type = string
}


variable "vpc_cidr" {
  type = string
}

variable "ssh_cidr" {
  description = "The allowed SSH IP address"
}



# variable "iam_instance_profile_names" {
#   type = list(string)
# }