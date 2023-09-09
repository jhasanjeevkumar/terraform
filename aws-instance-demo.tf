resource "aws_instance" "web1" {
    ami           = "${lookup(var.ami_id, var.region)}"
    instance_type = "t2.micro"
    key_name      = "${var.key_name}"
    vpc_security_group_ids = [aws_security_group.demo-first.id]
    subnet_id = aws_subnet.dpp-public-subnet-03.id

    user_data = <<-EOF
    #!/bin/bash
    echo "*** Installing apache2"
    sudo apt update -y
    sudo apt install apache2 -y
    echo "*** Completed Installing apache2"
    EOF

    tags ={
        default = "${var.server1}"
    }

    connection {
        type = "ssh"
        user = "ubuntu"
        private_key   = file("${var.private_key}")
        host = "${aws_instance.web1.public_ip}"
    }

    provisioner "file" {
        source = "index.html"
        destination = "/tmp/index.html"
    }

    //provisioner "remote-exec" {
    //    inline = [
    //        "sudo yum install -y httpd;sudo cp /tmp/index.html /var/www/html/",
    //        "sudo service httpd restart",
    //        "sudo service httpd status"
    //    ]
    //}


}

resource "aws_security_group" "demo-first" {
  name        = "demo-first"
  description = "SSH Access"
  vpc_id = aws_vpc.dpp-vpc.id 
  
  ingress {
    description      = "SHH access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }

    ingress {
    description      = "Jenkins port"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }

    ingress {
    description      = "Apache port"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ssh-prot"

  }
}

resource "aws_vpc" "dpp-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "dpp-vpc"
  }
  
}
resource "aws_subnet" "dpp-public-subnet-03" {
  vpc_id = aws_vpc.dpp-vpc.id
  cidr_block = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"
  tags = {
    Name = "dpp-public-subent-03"
  }
}

resource "aws_subnet" "dpp-public-subnet-04" {
  vpc_id = aws_vpc.dpp-vpc.id
  cidr_block = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1b"
  tags = {
    Name = "dpp-public-subent-04"
  }
}

resource "aws_internet_gateway" "dpp-igw" {
  vpc_id = aws_vpc.dpp-vpc.id 
  tags = {
    Name = "dpp-igw"
  } 
}

resource "aws_route_table" "dpp-public-rt" {
  vpc_id = aws_vpc.dpp-vpc.id 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dpp-igw.id 
  }
}

resource "aws_route_table_association" "dpp-rta-public-subnet-03" {
  subnet_id = aws_subnet.dpp-public-subnet-03.id
  route_table_id = aws_route_table.dpp-public-rt.id   
}

resource "aws_route_table_association" "dpp-rta-public-subnet-04" {
  subnet_id = aws_subnet.dpp-public-subnet-04.id 
  route_table_id = aws_route_table.dpp-public-rt.id   
}