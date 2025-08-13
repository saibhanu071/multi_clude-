variable "cluster_name" { type = string }
variable "region"       { type = string }
variable "vpc_cidr"     { type = string  default = "10.80.0.0/16" }
variable "node_instance_types" { type = list(string) default = ["t3.large"] }
variable "desired_size" { type = number default = 2 }
variable "max_size"     { type = number default = 4 }
variable "min_size"     { type = number default = 2 }
