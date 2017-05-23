variable "identifier" {}
variable "image_id" {}

resource "aws_launch_configuration" "main" {
  name_prefix          = "${var.identifier}-"
  image_id             = "${var.image_id}"
  instance_type        = "t2.nano"
  key_name             = "matschaffer_test"
  iam_instance_profile = "${aws_iam_instance_profile.profile.id}"

  user_data = <<BASH
#!/usr/bin/env bash

echo NOT changable user data
BASH

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_instance_profile" "profile" {
  name = "${var.identifier}"
  path = "/terraform/test/services/${var.identifier}/"
  role = "${aws_iam_role.role.name}"
}

resource "aws_iam_role" "role" {
  name               = "${var.identifier}"
  path               = "/terraform/test/services/${var.identifier}/"
  assume_role_policy = "${data.aws_iam_policy_document.instance-assume-role-policy.json}"
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

output "launch_configuration_id" {
  value = "${aws_launch_configuration.main.id}"
}
