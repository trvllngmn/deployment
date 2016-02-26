resource "aws_route53_record" "register" {
  zone_id = "${var.dns_zone_id}"
  name = "${var.id}.${var.vpc_name}.${var.dns_domain}"
  type = "CNAME"
  ttl = "${var.dns_ttl}"
  records = [ "${aws_elb.register.dns_name}" ]
}