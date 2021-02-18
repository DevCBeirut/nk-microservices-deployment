variable "region" {}
variable "profile" {
    default = "default"
}

variable "instance_type" {}
variable "key_name" {}
variable "amis" {
    type = map(string)
    default = {
        "eu-west-1" = "ami-0dc8d444ee2a42d8a"
        "eu-west-2" = "ami-09b984029e6b0326b"
    }
}