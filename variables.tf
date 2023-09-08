variable "key_name" {}
variable "region" {
    default = "us-east-1"
}
variable "ami_id" {
    type = map
    default = {
        us-east-1 = "ami-053b0d53c279acc90"
   }
}
