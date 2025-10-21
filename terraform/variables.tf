variable "instance_type" {
  type = string                     # The type of the variable, in this case a string
  default = "t2.medium"                 # Default value for the variable
  description = "The type of EC2 instance" # Description of what this variable represents
}

variable "worker_instance_name" {
  description = "Value of the EC2 instance's Name tag."
  type        = string
  default     = "blog-worker"
}

variable "control_instance_name" {
  description = "Value of the EC2 instance's Name tag."
  type        = string
  default     = "blog-controller"
}

variable "worker_count" {
  description = "The EC2 worker instance's count."
  type        = number
  default     = 2
}

variable "sg_name" {
  description = "The K8s cluster security group name."
  type        = string
  default     = "blog-sg"
}