resource "aws_iam_server_certificate" "certificate" {
  name_prefix = "${var.id}"
  path = "${var.path}"
  certificate_body = "${file(var.certificate_file)}"
  certificate_chain = "${file(var.chain_file)}"
  private_key = "${file(var.private_key_file)}"
  count = "${var.enabled}"
  lifecycle = {
    create_before_destroy = true
  }
}
