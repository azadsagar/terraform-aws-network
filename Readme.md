# terraform-aws-network module
This module helps you create a Network (VPC), with public, private and db subnets along with VPC Flow logging in s3 bucket.
Adds NAT gateway to your subnet and optionally helps you with multi-az NAT gatway.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.20 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_flow_log.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.natgw_route](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.db](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.private_rt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.pub_rt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_s3_bucket.flog_log](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_subnet.db_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_caller_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Tags as Key/Value pair map. These tags are attached all the resources created by module | `map(string)` | `{}` | no |
| <a name="input_auto_assign_public_ips_to_public_subnet_resources"></a> [auto\_assign\_public\_ips\_to\_public\_subnet\_resources](#input\_auto\_assign\_public\_ips\_to\_public\_subnet\_resources) | When set to true, resources created in public subnets will be associated with public ip address by default. Default is to true. This can be overriden during the individual resources creation like EC2 | `bool` | `true` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Default AWS Region where this module should create resources | `string` | `"us-east-1"` | no |
| <a name="input_azs"></a> [azs](#input\_azs) | Availability Zones as list, default is empty. If not provided, AZs will be autoassigned during subnet creation | `list(string)` | `[]` | no |
| <a name="input_enable_dns_hostnamed"></a> [enable\_dns\_hostnamed](#input\_enable\_dns\_hostnamed) | This allows your resources to be accessed via aws allocated internal dns names, default is true | `bool` | `true` | no |
| <a name="input_enable_multiaz_nat_gateway"></a> [enable\_multiaz\_nat\_gateway](#input\_enable\_multiaz\_nat\_gateway) | Weather to create multiple NAT Gateways per AZ for high availability. Default is set to false. Number of NAT Gateways Created are equal to the numebr AZS available or Public subnet, Whichever is less | `bool` | `false` | no |
| <a name="input_enable_vpc_flow_logs"></a> [enable\_vpc\_flow\_logs](#input\_enable\_vpc\_flow\_logs) | Enables VPC Flow logs. Default is false. You should enable this for audit and compliance | `bool` | `false` | no |
| <a name="input_ipv4_db_subnet_cidrs"></a> [ipv4\_db\_subnet\_cidrs](#input\_ipv4\_db\_subnet\_cidrs) | List of IPv4 CIDR Block for DB subnets. Default is empty list, No DB subnets will be created | `list(string)` | `[]` | no |
| <a name="input_ipv4_primary_cidr_block"></a> [ipv4\_primary\_cidr\_block](#input\_ipv4\_primary\_cidr\_block) | Primary VPC CIDR Block. Example 10.30.0.0/16 | `string` | n/a | yes |
| <a name="input_ipv4_private_subnet_cidrs"></a> [ipv4\_private\_subnet\_cidrs](#input\_ipv4\_private\_subnet\_cidrs) | List of IPv4 CIDR Block for Private subnets. Default is empty list, No private subnets will be created | `list(string)` | `[]` | no |
| <a name="input_ipv4_public_subnet_cidrs"></a> [ipv4\_public\_subnet\_cidrs](#input\_ipv4\_public\_subnet\_cidrs) | List of IPv4 CIDR Block for Public subnets. Default is empty list, No public subnets will be created | `list(string)` | `[]` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace used as one of the combination for tags prefix. Usually goes to Name tag | `string` | `"example"` | no |
| <a name="input_stage"></a> [stage](#input\_stage) | Stage used as one of the combination for tags prefix. Usually goes to Name tag and helps identify environment. Default is set to `dev` | `string` | `"dev"` | no |
| <a name="input_use_nat_gateway"></a> [use\_nat\_gateway](#input\_use\_nat\_gateway) | If NAT gateway should be created be Private subnet. Default is set to true | `bool` | `true` | no |
| <a name="input_vpc_flow_logs_default_bucket"></a> [vpc\_flow\_logs\_default\_bucket](#input\_vpc\_flow\_logs\_default\_bucket) | VPC flow logs bucket to be used, if `enable_vpc_flow_logs` is set to `true`. If not set bucket name will be prefixed by `${local.tag_prefix}-${data.aws_caller_identity.this.account_id}` | `string` | `""` | no |
| <a name="input_vpc_flow_logs_traffic_type"></a> [vpc\_flow\_logs\_traffic\_type](#input\_vpc\_flow\_logs\_traffic\_type) | The type of traffic to capture. Valid values: `ACCEPT`, `REJECT`, `ALL` | `string` | `"ALL"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_subnet"></a> [db\_subnet](#output\_db\_subnet) | returns the map with list of `id` and `ipv4_cidrs`. Example accessing first db subnet id: `module.<modulename>.db_subnet.id[0]` |
| <a name="output_private_subnet"></a> [private\_subnet](#output\_private\_subnet) | returns the map with list of `id` and `ipv4_cidrs`. Example accessing first private subnet id: `module.<modulename>.private_subnet.id[0]` |
| <a name="output_public_subnet"></a> [public\_subnet](#output\_public\_subnet) | returns the map with list of `id` and `ipv4_cidrs`. Example accessing first public subnet id: `module.<modulename>.public_subnet.id[0]` |
| <a name="output_vpc"></a> [vpc](#output\_vpc) | returns the map with `id` and `primary_vpc_cidr`. Example accessing vpc id: `module.<modulename>.vpc.id` |
