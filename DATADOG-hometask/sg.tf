resource "aws_security_group" "ssh_inbound" {
  name        = "ssh-inbound"
  description = "allows ssh access from safe IP-range"
  vpc_id      = aws_vpc.public.id
  tags = merge(
    var.tags,
    {
      Name = "${var.n_s}-ssh-inbound"
    },
  )
}

resource "aws_security_group_rule" "ssh_inbound" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.my_ip]
  security_group_id = aws_security_group.ssh_inbound.id
  description       = "allows ssh access from my IP"
}

resource "aws_security_group_rule" "outbound" {
  type              = "egress"
  to_port           = 0
  protocol          = "-1"
  from_port         = 0
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ssh_inbound.id
}
