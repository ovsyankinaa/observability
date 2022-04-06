variable "tags" {
  type        = map(string)
  description = "Tags for all created resources"
  default = {
    "Terraform" = "True"
    "Project"   = "DATADOG"
    "Owner"     = "Aliaksandr_Ausiankin"
  }
}

variable "my_ip" {
  type        = string
  description = "My public IP address"
  default     = "37.212.4.126/32"
}

variable "n_s" {
  type        = string
  description = "Name Surname"
  default     = "Aliaksandr-Ausiankin"
}

variable "ssh_key" {
  type        = string
  description = "Provides custom ssh key"
}
