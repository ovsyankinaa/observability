resource "aws_instance" "DATADOG" {
  ami                    = "ami-08ca3fed11864d6bb"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ssh_inbound.id]
  key_name               = aws_key_pair.public.key_name
  user_data = file("files/user_data.sh")

  tags = merge(
    var.tags,
    {
      Name = "${var.n_s}-DATADOG"
    },
  )
}
