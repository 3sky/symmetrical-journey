variable "project" {
  description = "Your GCP Project ID"
  type        = string
}

variable "high_avaiability" {
  description = "Do you need HA?"
  type = bool
  default = true
}
