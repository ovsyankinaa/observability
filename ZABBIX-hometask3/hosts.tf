resource "aws_instance" "ZABBIX_server" {
  ami                    = "ami-08ca3fed11864d6bb"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ssh_inbound.id]
  key_name               = aws_key_pair.public.key_name
  user_data = templatefile("files/user_data.sh", {
  zabbix_db_passwd = "${var.zabbix_db_passwd}" })

  tags = merge(
    var.tags,
    {
      Name = "${var.n_s}-ZABBIX"
    },
  )
}

resource "aws_instance" "ZABBIX_client" {
  ami                    = "ami-08ca3fed11864d6bb"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ssh_inbound.id]
  key_name               = aws_key_pair.public.key_name
  user_data              = templatefile("files/user_data_client.sh", {
    zabbix_server_ip = "${aws_instance.ZABBIX_server.private_ip}"
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.n_s}-ZABBIX-CLIENT"
    },
  )
}
