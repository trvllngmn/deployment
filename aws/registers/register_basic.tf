module "basic" {
  source = "../modules/register"
  id = "basic"
  instance_count = "${lookup(var.instance_count, "basic")}"
  instance_type = "t2.medium"
  instance_ami = "ami-c51e3eb6"

  vpc_name = "${var.vpc_name}"
  vpc_id = "${module.core.vpc_id}"
  private_dns_zone_id = "${module.core.private_dns_zone_id}"
  subnet_ids = "${module.openregister.subnet_ids}"
  public_subnet_ids = "${module.core.public_subnet_ids}"
  security_group_ids = ["${module.openregister.security_group_id}"]
  user_data = "${data.template_file.user_data.rendered}"

  dns_zone_id = "${module.core.dns_zone_id}"
  certificate_arn = "${var.elb_certificate_arn}"

  enable_availability_checks = "${var.enable_availability_checks}"

  registers = ["${var.multitenancy_groups["basic"]}"]
}