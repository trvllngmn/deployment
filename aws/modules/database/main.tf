resource "aws_db_instance" "db" {
  identifier = "${var.id}"
  instance_class = "${var.instance_class}"

  count = "${var.count}"
  multi_az = "${var.multi_az}"
  publicly_accessible = "false"

  allocated_storage = "${var.allocated_storage}"
  backup_retention_period = "${var.backup_retention_period}"
  maintenance_window = "${var.maintenance_window}"

  engine = "${var.engine}"
  engine_version = "${var.engine_version}"

  db_subnet_group_name = "${aws_db_subnet_group.subnet_group.id}"
  parameter_group_name = "${var.parameter_group_name}"

  username = "${var.username}"
  password = "${var.password}"

  tags = {
    Name = "${var.id}"
    Environment = "${var.vpc_name}"
  }
}
