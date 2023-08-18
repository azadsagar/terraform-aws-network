variable "ipv4_primary_cidr_block" {
  type        = string
  description = "Primary VPC CIDR Block. Example 10.30.0.0/16"
}

variable "enable_vpc_flow_logs" {
  type        = bool
  description = "Enables VPC Flow logs. Default is false. You should enable this for audit and compliance"
  default     = false
}

variable "vpc_flow_logs_default_bucket" {
  type        = string
  default     = ""
  description = "VPC flow logs bucket to be used, if `enable_vpc_flow_logs` is set to `true`. If not set bucket name will be prefixed by `$${local.tag_prefix}-$${data.aws_caller_identity.this.account_id}`"
  validation {
    condition     = length(var.vpc_flow_logs_default_bucket) <= 63
    error_message = "bucket name should be less than 63 chars"
  }
}

variable "vpc_flow_logs_traffic_type" {
  type        = string
  description = "The type of traffic to capture. Valid values: `ACCEPT`, `REJECT`, `ALL`"
  default     = "ALL"
  nullable    = false
  validation {
    condition     = contains(["ALL", "ACCEPT", "REJECT"], var.vpc_flow_logs_traffic_type)
    error_message = "Invalid value of `vpc_flow_logs_traffic_type`. Valid values: `ACCEPT`, `REJECT`, `ALL`"
  }
}

variable "enable_dns_hostnames" {
  type        = bool
  default     = true
  description = "This allows your resources to be accessed via aws allocated internal dns names, default is true"
}

variable "azs" {
  type        = list(string)
  default     = []
  description = "Availability Zones as list, default is empty. If not provided, AZs will be autoassigned during subnet creation"
}

variable "additional_tags" {
  type        = map(string)
  default     = {}
  description = "Tags as Key/Value pair map. These tags are attached all the resources created by module"
}

variable "namespace" {
  type        = string
  default     = "example"
  description = "Namespace used as one of the combination for tags prefix. Usually goes to Name tag"
}

variable "stage" {
  type        = string
  default     = "dev"
  description = "Stage used as one of the combination for tags prefix. Usually goes to Name tag and helps identify environment. Default is set to `dev`"
}

variable "ipv4_public_subnet_cidrs" {
  type        = list(string)
  default     = []
  description = "List of IPv4 CIDR Block for Public subnets. Default is empty list, No public subnets will be created"
}

variable "ipv4_private_subnet_cidrs" {
  type        = list(string)
  default     = []
  description = "List of IPv4 CIDR Block for Private subnets. Default is empty list, No private subnets will be created"
}

variable "ipv4_db_subnet_cidrs" {
  type        = list(string)
  default     = []
  description = "List of IPv4 CIDR Block for DB subnets. Default is empty list, No DB subnets will be created"
}

variable "auto_assign_public_ips_to_public_subnet_resources" {
  type        = bool
  default     = true
  description = "When set to true, resources created in public subnets will be associated with public ip address by default. Default is to true. This can be overriden during the individual resources creation like EC2"
}

variable "use_nat_gateway" {
  type        = bool
  default     = true
  description = "If NAT gateway should be created be Private subnet. Default is set to true"
}

variable "enable_multiaz_nat_gateway" {
  type        = bool
  default     = false
  description = "Weather to create multiple NAT Gateways per AZ for high availability. Default is set to false. Number of NAT Gateways Created are equal to the numebr AZS available or Public subnet, Whichever is less"
}