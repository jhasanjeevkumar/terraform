output "instance_ip" {
    value = ["${aws_instance.web1.public_ip}"]
}