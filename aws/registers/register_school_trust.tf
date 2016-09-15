module "school-trust_policy" {
  source = "../modules/instance_policy"
  id = "school-trust"
  enabled = "${signum(lookup(var.instance_count, "school-trust"))}"

  vpc_name = "${var.vpc_name}"
  vpc_id = "${module.core.vpc_id}"
}

module "school-trust_openregister" {
  source = "../modules/instance"
  id = "school-trust"
  role = "openregister_app"

  vpc_name = "${var.vpc_name}"
  vpc_id = "${module.core.vpc_id}"

  subnet_ids = "${module.openregister.subnet_ids}"
  security_group_ids = ["${module.openregister.security_group_id}"]

  instance_count = "${lookup(var.instance_count, "school-trust")}"
  iam_instance_profile = "${module.school-trust_policy.profile_name}"

  user_data = "${data.template_file.user_data.rendered}"
}

module "school-trust_elb" {
  source = "../modules/load_balancer"
  id = "school-trust"
  enabled = "${signum(lookup(var.instance_count, "school-trust"))}"

  vpc_name = "${var.vpc_name}"
  vpc_id = "${module.core.vpc_id}"

  instance_ids = "${module.school-trust_openregister.instance_ids}"
  security_group_ids = ["${module.openregister.security_group_id}"]
  subnet_ids = "${module.core.public_subnet_ids}"

  dns_zone_id = "${module.core.dns_zone_id}"
  certificate_arn = "${var.elb_certificate_arn}"
}