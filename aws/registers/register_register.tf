module "register_policy" {
  source = "../modules/instance_policy"
  id = "register"
  enabled = "${signum(lookup(var.instance_count, "register"))}"

  vpc_name = "${var.vpc_name}"
  vpc_id = "${module.core.vpc_id}"
}

module "register_presentation" {
  source = "../modules/instance"
  id = "register"
  role = "presentation_app"

  vpc_name = "${var.vpc_name}"
  vpc_id = "${module.core.vpc_id}"

  subnet_ids = "${module.presentation.subnet_ids}"
  security_group_ids = "${module.presentation.security_group_id}"

  instance_count = "${lookup(var.instance_count, "register")}"
  iam_instance_profile = "${module.register_policy.profile_name}"

  user_data = "${template_file.user_data.rendered}"
}

module "register_mint" {
  source = "../modules/instance"
  id = "register"
  role = "mint_app"

  vpc_name = "${var.vpc_name}"
  vpc_id = "${module.core.vpc_id}"

  subnet_ids = "${module.mint.subnet_ids}"
  security_group_ids = "${module.mint.security_group_id}"

  instance_count = "${signum(lookup(var.instance_count, "register"))}"
  iam_instance_profile = "${module.register_policy.profile_name}"

  user_data = "${template_file.user_data.rendered}"
}

module "register_openregister" {
  source = "../modules/instance"
  id = "register"
  role = "openregister_app"

  vpc_name = "${var.vpc_name}"
  vpc_id = "${module.core.vpc_id}"

  subnet_ids = "${module.openregister.subnet_ids}"
  security_group_ids = "${module.openregister.security_group_id}"

  instance_count = "${lookup(var.instance_count, "register")}"
  iam_instance_profile = "${module.register_policy.profile_name}"

  user_data = "${template_file.user_data.rendered}"
}

module "register_elb" {
  source = "../modules/load_balancer"
  id = "register"
  enabled = "${signum(lookup(var.instance_count, "register"))}"

  vpc_name = "${var.vpc_name}"
  vpc_id = "${module.core.vpc_id}"

  instance_ids = "${module.register_presentation.instance_ids}"
  security_group_ids = "${module.presentation.security_group_id}"
  subnet_ids = "${module.core.public_subnet_ids}"

  dns_zone_id = "${module.core.dns_zone_id}"
  certificate_arn = "${var.elb_certificate_arn}"
}
