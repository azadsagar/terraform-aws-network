
resource "aws_vpc" "this" {
  cidr_block           = var.ipv4_primary_cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge({
    Name = "${local.tag_prefix}-vpc"
  }, var.additional_tags)

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_subnet" "public_subnet" {
  count      = local.public_subnet_count
  cidr_block = var.ipv4_public_subnet_cidrs[count.index]
  vpc_id     = aws_vpc.this.id

  availability_zone = local.azs_count > 0 ? var.azs[local.public_subnet_count % local.azs_count] : null

  map_public_ip_on_launch = var.auto_assign_public_ips_to_public_subnet_resources

  tags = merge({
    Name = "${local.tag_prefix}-pub-sub-${count.index + 1}"
  }, var.additional_tags)

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_subnet" "private_subnet" {
  count      = local.private_subnet_count
  cidr_block = var.ipv4_private_subnet_cidrs[count.index]
  vpc_id     = aws_vpc.this.id

  availability_zone = local.azs_count > 0 ? var.azs[local.private_subnet_count % local.azs_count] : null

  map_public_ip_on_launch = false

  tags = merge({
    Name = "${local.tag_prefix}-priv-sub-${count.index + 1}"
  }, var.additional_tags)

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_subnet" "db_subnet" {
  count      = local.db_subnet_count
  vpc_id     = aws_vpc.this.id
  cidr_block = var.ipv4_db_subnet_cidrs[count.index]

  availability_zone = local.azs_count > 0 ? var.azs[local.db_subnet_count % local.azs_count] : null

  map_public_ip_on_launch = false

  tags = merge({
    Name = "${local.tag_prefix}-db-sub-${count.index + 1}"
  })

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_internet_gateway" "this" {
  tags = merge({
    Name = "${local.tag_prefix}-igw"
  }, var.additional_tags)
  vpc_id = aws_vpc.this.id

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_eip" "this" {
  count = var.use_nat_gateway ? var.enable_multiaz_nat_gateway && local.public_subnet_count > 1 ? local.azs_count : 1 : 0

  depends_on = [aws_internet_gateway.this]

  tags = merge({
    Name = "${local.tag_prefix}-ngw-eip-${count.index + 1}"
  }, var.additional_tags)

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_nat_gateway" "this" {
  count      = var.use_nat_gateway ? var.enable_multiaz_nat_gateway && local.public_subnet_count > 1 ? local.azs_count : 1 : 0
  depends_on = [aws_eip.this]

  allocation_id = element(aws_eip.this.*.id, count.index)
  subnet_id     = element(aws_subnet.public_subnet.*.id, local.public_subnet_count > local.azs_count ? count.index % local.public_subnet_count : count.index)

  tags = merge({
    Name = "${local.tag_prefix}-natgw-${count.index + 1}"
  }, var.additional_tags)

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags = merge({
    Name = "${local.tag_prefix}-pub-rt"
  }, var.additional_tags)

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_route" "igw" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.this.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "pub_rt" {
  count          = local.public_subnet_count
  route_table_id = aws_route_table.public.id
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
}

resource "aws_route_table" "private" {

  count = var.use_nat_gateway && var.enable_multiaz_nat_gateway ? local.azs_count : 1

  vpc_id = aws_vpc.this.id

  tags = merge({
    Name = "${local.tag_prefix}-priv-rt"
  }, var.additional_tags)

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_route" "natgw_route" {
  count          = var.use_nat_gateway && var.enable_multiaz_nat_gateway ? local.azs_count : 1
  route_table_id = element(aws_route_table.private.*.id, count.index)

  gateway_id             = element(aws_nat_gateway.this.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
}

#resource "aws_route_table_association" "private_rt" {
#  count          = local.private_subnet_count
#  route_table_id = element(aws_route_table.private.*.id, count.index % local.azs_count)
#  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
#}

resource "aws_route_table_association" "private_rt" {
  count          = var.use_nat_gateway && var.enable_multiaz_nat_gateway ? 0 : local.private_subnet_count
  route_table_id = element(aws_route_table.private.*.id, 0)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
}

resource "aws_route_table_association" "private_rt1" {
  count          = var.use_nat_gateway && var.enable_multiaz_nat_gateway ? local.private_subnet_count : 0
  route_table_id = element(aws_route_table.private.*.id, count.index % local.azs_count)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
}

resource "aws_route_table" "db" {
  vpc_id = aws_vpc.this.id

  tags = merge({
    Name = "${local.tag_prefix}-db-rt"
  }, var.additional_tags)

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_route_table_association" "db" {
  count          = local.db_subnet_count
  route_table_id = aws_route_table.db.id

  subnet_id = element(aws_subnet.db_subnet.*.id, count.index)
}

resource "aws_s3_bucket" "flow_log" {
  count  = var.enable_vpc_flow_logs ? 1 : 0
  bucket = local.vpc_flow_logs_bucket

  tags = merge({
    Name = local.vpc_flow_logs_bucket
  }, var.additional_tags)

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "flow_log" {
  count  = var.enable_vpc_flow_logs ? 1 : 0
  bucket = element(aws_s3_bucket.flow_log.*.id, count.index)

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "policy" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  bucket     = local.vpc_flow_logs_bucket
  policy     = element(data.aws_iam_policy_document.bucket.*.json, count.index)
  depends_on = [aws_s3_bucket.flow_log]
}

resource "aws_flow_log" "vpc" {
  count = var.enable_vpc_flow_logs ? 1 : 0

  traffic_type         = var.vpc_flow_logs_traffic_type
  log_destination      = element(aws_s3_bucket.flow_log.*.arn, count.index)
  log_destination_type = "s3"
  vpc_id               = aws_vpc.this.id
  destination_options {
    file_format        = "parquet"
    per_hour_partition = true
  }
}
