resource "aws_instance" "prod_locust" {
    ami = "ami-0fc5d935ebf8bc3bc"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.prod_locust.id]
    subnet_id = aws_subnet.prod_public_1.id
    associate_public_ip_address = true
    user_data = base64encode(<<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y python3-pip python3-venv git

    git clone https://github.com/DomRuanSuzano/locust.git /home/ubuntu/locust
    sudo chown -R ubuntu:ubuntu ~/locust
    cd /home/ubuntu/locust

    export API_URL="http://${aws_lb.prod.dns_name}"

    python3 -m venv venv
    source venv/bin/activate
    pip install -r requirements.txt

    locust -f locust.py

    EOF
    )
    tags = {
        Name = "prod-locust"
    }
}

resource "aws_security_group" "prod_locust" {
    name = "prod-locust"
    description = "Security group for locust"
    vpc_id = aws_vpc.prod.id
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}