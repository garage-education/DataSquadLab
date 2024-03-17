variable "external_secret_name" {}

variable "refresh_rate" {
  default = "1h"
}
variable "external_secret_store_name" {}
variable "namespace_name" {}

variable "secret_map" {
  type = list(object({
    external_sm_name          = string
    external_sm_name_key      = string
    k8s_property_key = string
  }))
  default = []
}
