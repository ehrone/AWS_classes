output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_a_id" {
  value = aws_subnet.public_subnet_a.id
}

output "private_subnet_a_id" {
  value = aws_subnet.private_subnet_a.id
}
