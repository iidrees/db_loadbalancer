# instance to be provisioned 
resource "aws_instance" "master_db_server" {
 
  ami = "${var.ami_image_id}"
  instance_type = "t2.micro"
  key_name = "cp-devops"
  tags = {
    Name = "master-db"
  }
}

# Associating the EIP to the instance
resource "aws_eip_association" "eip_assoc" {
  instance_id   = "${aws_instance.master_db_server.id}"
  public_ip = "${var.master_eip}"
}

