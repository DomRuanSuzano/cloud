output "aws_lb_dns_name" {
    value = aws_lb.prod.dns_name
}

output "aws_vpc_id" {
    value = aws_vpc.prod.id
}