# Aplication load balancer for production
resource "aws_lb" "prod" {
  name               = "prod"
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.prod_lb.id]
  subnets            = [aws_subnet.prod_public_1.id, aws_subnet.prod_public_2.id]
  enable_deletion_protection = false
  depends_on = [aws_autoscaling_group.prod_backend]
}

# Target group for backend web application
resource "aws_lb_target_group" "prod_backend" {
  name        = "prod-backend"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.prod.id

  health_check {
    enabled             = true 
    path                = "/docs"
    port                = "80"
    protocol            = "HTTP"
    healthy_threshold   = 5
    unhealthy_threshold = 5
    timeout             = 29
    interval            = 30
  }
}

# Target listener for http:80
resource "aws_lb_listener" "prod_http" {
  load_balancer_arn = aws_lb.prod.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prod_backend.arn
  }
}

# Allow traffic from 80 and 443 ports only
resource "aws_security_group" "prod_lb" {
  name        = "prod-lb"
  description = "Controls access to the ALB"
  vpc_id      = aws_vpc.prod.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
