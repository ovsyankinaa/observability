variable "tags" {
  type        = map(string)
  description = "Tags for all created resources"
  default = {
    "Terraform" = "True"
    "Project"   = "ZABBIX"
    "Owner"     = "Aliaksandr_Ausiankin"
  }
}

variable "my_ip" {
  type        = string
  description = "My public IP address"
  default     = "37.212.2.62/32"
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

variable "zabbix_db_passwd" {
  type        = string
  description = "Provides custom ssh key"
}
