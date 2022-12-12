variable "location" {
  default = "West Europe"
  description = "Region to deploy the VM to"
}

variable "location_short" {
  default = "we"
  description = "Region to deploy the VM to"
}

variable "environment" {
  description = "Region to deploy the VM to"
  default = "common"
}

variable "resource_group_name" {
  description = "RG to deploy resource to"
}

variable "subnet_id" {
  description = "subnet id to deploy resources to"
}

variable "vm_size" {
  default = "Standard_B1s"
}

variable "admin_ssh_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQBsUy8OllCkhpOU4FplN1b7ypawC/8QM++3gb9EbqZHCJnJdTNhk/0QZVvGsPvWeSazsShgX2TdEMMdDFscWDdAfnoB+hyjhFyWaOfKXFdzafib3HrO0rGUPqW42V6d0N2V5rh23ZFZGX5Bp75KEFnrFgGY1axCebvMvStGzXXffole1sCt0SKbvFptc/MT/ZVSqT0i0ugS0dVXsb4kuo4qnNRUAqvunljDL5oS3ZT7bQtjAvcw+IyYF6Ka9pGc4EuNaYZ2YuaxMyMOKYoMq4Qz8Qk5oF34ATGCPC0SdAgtAByNblbYeB6s+ueWUwSEcKOfIKjl9lxJasCRBRkjl7zp non-prod-test"
}

variable "index_number" {
  default = 01
}

locals {
  vm = {
    vm_name = "${var.location_short}-${var.environment}-${var.index_number}-vm"
    nic_name = "${var.location_short}-${var.environment}-${var.index_number}-nic"
  }
}