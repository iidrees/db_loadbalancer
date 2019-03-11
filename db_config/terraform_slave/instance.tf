# instances to be provisioned 
resource "aws_instance" "slave_db_server1" {
  ami = "${var.ami_image_id}"
  instance_type = "t2.micro"
  key_name = "cp-devops"
  tags = {
    Name = "slave-db1"
  }
}
resource "aws_instance" "slave_db_server2" {
  ami = "${var.ami_image_id}"
  instance_type = "t2.micro"
  key_name = "cp-devops"
  tags = {
    Name = "slave-db2"
  }
  
}

# Elastic IPs for the above slave instances
resource "aws_eip_association" "eip_assoc1" {
  instance_id   = "${aws_instance.slave_db_server1.id}"
  public_ip = "${var.slave1_eip}"
}

resource "aws_eip_association" "eip_assoc2" {
  instance_id   = "${aws_instance.slave_db_server2.id}"
  public_ip = "${var.slave2_eip}"
}

