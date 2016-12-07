resource "statuscake_test" "status_check_home" {
  website_name = "${var.vpc_name} - ${var.id} (${var.dns_domain}) - home"
  website_url = "https://${aws_route53_record.load_balancer.fqdn}"
  test_type = "HTTP"
  check_rate = 300
  count = "${signum(var.enable_availability_checks * var.instance_count)}"
}

resource "statuscake_test" "status_check_records" {
  website_name = "${var.vpc_name} - ${var.id} (${var.dns_domain}) - records"
  website_url = "https://${aws_route53_record.load_balancer.fqdn}/records"
  test_type = "HTTP"
  check_rate = 300
  count = "${signum(var.enable_availability_checks * var.instance_count)}"
}
