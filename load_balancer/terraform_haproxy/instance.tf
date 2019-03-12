# instance to be provisioned 
resource "aws_instance" "haproxy_lb" {
  # instance_tags = {
  #   name = "master-db"
  # }
  ami = "${var.ami_image_id}"
  instance_type = "t2.micro"
  key_name = "cp-devops"
  tags = {
    Name = "haproxy-lb"
  }
}


resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.haproxy_lb.id}"
  public_ip = "${var.haproxy_eip}"
}

