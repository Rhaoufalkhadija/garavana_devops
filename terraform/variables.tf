variable "aws_region" {
  description = "Region AWS"
  type        = string
  default     = "us-east-1"
}

variable "key_name" {
  description = "Nom de la key pair AWS (sans .pem)"
  type        = string
}

variable "ami_id" {
  description = "AMI Amazon Linux 2 (us-east-1)"
  type        = string
  default     = "ami-0c02fb55956c7d316"
}
