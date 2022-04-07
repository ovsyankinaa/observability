resource "aws_instance" "PROMETHEUS" {
  ami                    = "ami-08ca3fed11864d6bb"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ssh_inbound.id]
  key_name               = aws_key_pair.public.key_name
  user_data = templatefile("files/user_data.sh", {
    prometheus_client_ip = "${aws_instance.PROMETHEUS_client.private_ip}"
  })

  tags = merge(
    var.tags,
    {
      Name = "${var.n_s}-PROMETHEUS"
    },
  )
}

resource "aws_instance" "PROMETHEUS_client" {
  ami                    = "ami-08ca3fed11864d6bb"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ssh_inbound.id]
  key_name               = aws_key_pair.public.key_name
  user_data              = file("files/user_data_client.sh")

  tags = merge(
    var.tags,
    {
      Name = "${var.n_s}-PROMETHEUS-CLIENT"
    },
  )
}
