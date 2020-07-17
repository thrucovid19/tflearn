variable "credentials" {
  default = "~/.aws/credentials"
}

variable "region" {
  description = "EC2 Region for the VPC"
  default     = "us-east-1"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}

variable "elb_port" {
  description = "The port the ELB will use for HTTP requests"
  type        = number
  default     = 80
}