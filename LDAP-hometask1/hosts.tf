resource "aws_instance" "LDAP_server" {
  ami                    = "ami-0069d66985b09d219"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ssh_inbound.id]
  key_name               = aws_key_pair.public.key_name
  user_data = templatefile("files/user_data.sh", {
    ldap_root_passwd = "${var.ldap_root_passwd}",
    ldap_user_passwd = "${var.ldap_user_passwd}",
  personal_ip = "${var.my_ip}" })

  tags = merge(
    var.tags,
    {
      Name = "${var.n_s}-LDAP"
    },
  )
}

resource "aws_instance" "LDAP_client" {
  ami                    = "ami-0069d66985b09d219"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ssh_inbound.id]
  key_name               = aws_key_pair.public.key_name
  user_data = templatefile("files/user_data_client.sh", {
  ldap_server_ip = "${aws_instance.LDAP_server.private_ip}" })

  tags = merge(
    var.tags,
    {
      Name = "${var.n_s}-LDAP-CLIENT"
    },
  )
}
