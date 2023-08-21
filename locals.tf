locals {
  tag_prefix           = "${var.namespace}-${var.stage}"
  arn_format           = "arn:${data.aws_partition.current.partition}"
  public_subnet_count  = length(var.ipv4_public_subnet_cidrs)
  private_subnet_count = length(var.ipv4_private_subnet_cidrs)
  db_subnet_count      = length(var.ipv4_db_subnet_cidrs)
  azs_count            = length(var.azs)
  vpc_flow_logs_bucket = length(var.vpc_flow_logs_default_bucket) == 0 ? "${local.tag_prefix}-${data.aws_caller_identity.this.account_id}-vpc-flow-logs" : var.vpc_flow_logs_default_bucket
}