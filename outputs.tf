
output "vpc" {
  value = {
    id               = aws_vpc.this.id
    primary_vpc_cidr = var.ipv4_primary_cidr_block
  }
  description = "returns the map with `id` and `primary_vpc_cidr`. Example accessing vpc id: `module.<modulename>.vpc.id`"
}

output "public_subnet" {
  value = {
    id         = aws_subnet.public_subnet.*.id
    ipv4_cidrs = aws_subnet.public_subnet.*.cidr_block
  }
  description = "returns the map with list of `id` and `ipv4_cidrs`. Example accessing first public subnet id: `module.<modulename>.public_subnet.id[0]`"
}

output "private_subnet" {
  value = {
    id         = aws_subnet.private_subnet.*.id
    ipv4_cidrs = aws_subnet.private_subnet.*.cidr_block
  }
  description = "returns the map with list of `id` and `ipv4_cidrs`. Example accessing first private subnet id: `module.<modulename>.private_subnet.id[0]`"
}

output "db_subnet" {
  value = {
    id         = aws_subnet.db_subnet.*.id
    ipv4_cidrs = aws_subnet.db_subnet.*.cidr_block
  }
  description = "returns the map with list of `id` and `ipv4_cidrs`. Example accessing first db subnet id: `module.<modulename>.db_subnet.id[0]`"
}