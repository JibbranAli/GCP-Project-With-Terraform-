variable "project_id" {
  description = "GCP project id."
  type        = string
}

variable "region" {
  description = "GCP region."
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone."
  type        = string
  default     = "us-central1-a"
}

variable "name_prefix" {
  description = "Prefix used for resource names."
  type        = string
  default     = "webapp"
}

variable "subnet_cidr" {
  description = "CIDR for the subnet."
  type        = string
  default     = "10.10.1.0/24"
}

variable "machine_type" {
  description = "Machine type for instances."
  type        = string
  default     = "e2-micro"
}

variable "instance_count" {
  description = "Number of instances in the managed instance group."
  type        = number
  default     = 2
}

variable "data_disk_size_gb" {
  description = "Size of the attached data disk in GB."
  type        = number
  default     = 20
}

variable "enable_ssh" {
  description = "Whether to allow SSH access."
  type        = bool
  default     = true
}

variable "ssh_source_ranges" {
  description = "Allowed source ranges for SSH."
  type        = list(string)
  default     = ["35.235.240.0/20"]
}

variable "static_bucket_location" {
  description = "Location for the static assets bucket."
  type        = string
  default     = "US"
}

variable "force_destroy_static_bucket" {
  description = "Allow Terraform to delete objects in the static bucket."
  type        = bool
  default     = false
}

