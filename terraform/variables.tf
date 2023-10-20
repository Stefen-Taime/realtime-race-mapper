variable "region" {
  description = "The region to deploy the resources in."
  default     = "us-central1"
}

variable "zone" {
  description = "The zone to deploy the resources in."
  default     = "us-central1-a"
}

variable "credentials" {
  description = "The path to the Google Cloud credentials file."
  default     = "xxxxxxxxx"
}

variable "project" {
  description = "The ID of the Google Cloud project."
  default     = ""
}
