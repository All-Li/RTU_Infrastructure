# secrets.auto.tfvars
variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}
# ------------------------------------------------------
variable "ssh_public_key" {
  type    = string
  default = ".ssh/id_rsa.pub"
}