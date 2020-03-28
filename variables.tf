locals {
  labels = {
    source      = "terraform"
    Environment = terraform.workspace
  }
}

variable "hcloud_token" {
  type        = string
  description = "Hetzner cloud token"
}

variable "location" {
  type        = string
  description = "The location of the server"
  default     = "nbg1"
}

variable "ssh_key" {
  type = string
  description = "Your ssh key"
}