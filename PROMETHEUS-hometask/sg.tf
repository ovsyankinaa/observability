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

resource "aws_security_group_rule" "prometheus" {
  type              = "ingress"
  from_port         = 9090
  to_port           = 9090
  protocol          = "tcp"
  cidr_blocks       = [var.my_ip]
  security_group_id = aws_security_group.ssh_inbound.id
  description       = "allows access to prometetheus"
}

resource "aws_security_group_rule" "prometheus_node_exp" {
  type              = "ingress"
  from_port         = 9100
  to_port           = 9100
  protocol          = "tcp"
  cidr_blocks       = [aws_subnet.public.cidr_block]
  security_group_id = aws_security_group.ssh_inbound.id
  description       = "allows access prometheus node explorer"
}

resource "aws_security_group_rule" "prometheus_alert" {
  type              = "ingress"
  from_port         = 9093
  to_port           = 9093
  protocol          = "tcp"
  cidr_blocks       = [aws_subnet.public.cidr_block]
  security_group_id = aws_security_group.ssh_inbound.id
  description       = "allows access prometheus alert manager"
}

resource "aws_security_group_rule" "web" {
  type              = "ingress"
  from_port         = 9115
  to_port           = 9115
  protocol          = "tcp"
  cidr_blocks       = [var.my_ip]
  security_group_id = aws_security_group.ssh_inbound.id
  description       = "allows access to prometetheus"
}

resource "aws_security_group_rule" "grafana" {
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = [var.my_ip]
  security_group_id = aws_security_group.ssh_inbound.id
  description       = "allows access to prometetheus"
}
