resource "aws_key_pair" "public" {
  key_name   = "${var.n_s}-public-key"
  public_key = var.ssh_key
  tags       = var.tags
}