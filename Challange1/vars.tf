variable "resourcegroup" {
  description = "Name of the resourcegroup"
  default = "testrg"
}

variable "location" {
  description = "Azure location to use"
  default = "West US 2"
}

variable "vnet" {
  description = "Name of the vnet"
  default = "testvnet"
}

variable "vnet_address_space" {
  description = "Address space of vnet"
  default = ["10.0.0.0/16"]
}
