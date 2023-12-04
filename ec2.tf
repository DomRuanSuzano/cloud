resource aws_launch_template "prod_backend" {
    name = "prod-backend"
    image_id = "ami-0fc5d935ebf8bc3bc"
    instance_type = "t2.micro"
    
    user_data = base64encode(<<-EOF
    #!/bin/bash
    sudo touch app.log 
    export DEBIAN_FRONTEND=noninteractive

    sudo apt -y remove needrestart
    sudo apt-get update
    sudo apt-get install -y python3-pip python3-venv git

    # Criação do ambiente virtual e ativação
    python3 -m venv /home/ubuntu/myappenv
    
    source /home/ubuntu/myappenv/bin/activate
   

    # Clonagem do repositório da aplicação
    git clone https://github.com/DomRuanSuzano/aplicacao_cloud.git /home/ubuntu/myapp
    

    # Instalação das dependências da aplicação
    pip install -r /home/ubuntu/myapp/requirements.txt
    
    export INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    echo $INSTANCE_ID >> /home/ubuntu/myapp/app.log
    # Creating log stream...
    aws logs create-log-stream --log-group-name "prod-backend" --log-stream-name "prod-backend-web" --region us-east-1

    sudo apt-get install -y uvicorn
    
    # Configuração da variável de ambiente para o banco de dados
    export DATABASE_URL="mysql+pymysql://${var.prod_rds_username}:${var.prod_rds_password}@${aws_db_instance.prod_db_instance.endpoint}/${var.prod_rds_db_name}"

    # Setting up authbind for port 80...
    # sudo apt install authbind
    # sudo touch /etc/authbind/byport/80
    # sudo chmod 500 /etc/authbind/byport/80
    # sudo chown ubuntu /etc/authbind/byport/80
    
    cd /home/ubuntu/myapp
    # Inicialização da aplicação
    uvicorn main:app --host 0.0.0.0 --port 80 
  EOF
  )
    network_interfaces {
        associate_public_ip_address = true
        subnet_id = aws_subnet.prod_public_1.id
        security_groups = [aws_security_group.prod_ec2_backend.id]
    }
    iam_instance_profile {
        name = aws_iam_instance_profile.prod_ecs_backend.name
    }
    tag_specifications {
        resource_type = "instance"
        tags = {
            Name = "prod-backend"
        }
    }
}

resource "aws_autoscaling_group" "prod_backend" {
    name = "prod-backend"
    max_size = 5
    min_size = 1
    launch_template {
        id = aws_launch_template.prod_backend.id
        version = "$Latest"
    }
    vpc_zone_identifier = [aws_subnet.prod_public_1.id, aws_subnet.prod_public_2.id]
    target_group_arns = [aws_lb_target_group.prod_backend.arn]
    health_check_type = "EC2"
    health_check_grace_period = 300
    
    tag {
        key = "Name"
        value = "prod-backend"
        propagate_at_launch = true
    }
}


resource "aws_autoscaling_policy" "prod_backend_up" {
  name                   = "prod-backend-up"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.prod_backend.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}


resource "aws_security_group" "prod_ec2_backend" {
    name = "prod-ecs-backend"
    description = "Controls access to the ECS backend"
    vpc_id = aws_vpc.prod.id

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        security_groups = [aws_security_group.prod_lb.id]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_iam_role" "prod_backend_task" {
    name = "prod-ec2-backend"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Principal = {
                    Service = "ec2.amazonaws.com"
                }
                Effect = "Allow"
                Sid = ""
            }
        ]
    })
}

resource "aws_iam_role" "ec2_task_execution" {
    name = "ec2-task-execution"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRole"
                Principal = {
                    Service = "ecs-tasks.amazonaws.com"
                }
                Effect = "Allow"
                Sid = ""
            }
        ]
    })
}

resource "aws_iam_instance_profile" "prod_ecs_backend" {
    name = "prod-ecs-backend"
    role = aws_iam_role.prod_backend_task.name
}

resource "aws_iam_policy" "policies" {
    name = "prod_policies"
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                    "logs:CreateLogGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents",
                    "logs:DescribeLogStreams"
                ]
                Effect = "Allow"
                Resource = "*"
            },
            {
                Action = [
                    "rds:Describe*",
                ]
                Effect = "Allow"
                Resource = "*"
            },
            {
                Action = [
                    "secretsmanager:GetSecretValue",
                    "secretsmanager:DescribeSecret",
                ]
                Effect = "Allow"
                Resource = "*"
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "prod_backend_task" {
    role = aws_iam_role.prod_backend_task.name
    policy_arn = aws_iam_policy.policies.arn
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "prod_backend" {
    name = "prod-backend"
    retention_in_days = var.ec2_prod_backend_retention_days
}

resource "aws_cloudwatch_log_stream" "prod_backend_web" {
    name = "prod-backend-web"
    log_group_name = aws_cloudwatch_log_group.prod_backend.name
}