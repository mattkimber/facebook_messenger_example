# AWS settings

variable "region" {
	type = "string"
    default = "eu-west-1"
}

variable "access_key" {
	type = "string"
}

variable "secret_key" {
	type = "string"
}

variable "account_id" {
    type = "string"
}

# Facebook integration settings

variable "facebook_verify_token" {
	type = "string"
}

variable "facebook_page_token" {
    type = "string"
}
