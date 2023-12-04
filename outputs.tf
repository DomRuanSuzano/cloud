output "aws_lb_dns_name" {
    value = aws_lb.prod.dns_name
}

output "database_endpoint" {
    value = aws_db_instance.prod_db_instance.endpoint
}