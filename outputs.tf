output "aws_lb_dns_name" {
    value = aws_lb.prod.dns_name
}

output "locust_url" {
    value = aws_instance.prod_locust.public_ip
}