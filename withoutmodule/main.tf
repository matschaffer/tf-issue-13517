provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "xenial" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-20170516"]
  }

  filter {
    name   = "owner-id"
    values = ["099720109477"]
  }
}

variable "identifier" {
  default = "matschaffer-test"
}

variable "subnet_id" {
  description = "Specified using TF_VAR_subnet_id to keep account IDs out of github issue"
}

resource "aws_launch_configuration" "main" {
  name_prefix          = "${var.identifier}-"
  image_id             = "${data.aws_ami.xenial.id}"
  instance_type        = "t2.nano"
  key_name             = "matschaffer_test"
  iam_instance_profile = "${aws_iam_instance_profile.profile.id}"

  user_data = <<BASH
#!/usr/bin/env bash

echo changable user data
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

resource "aws_autoscaling_group" "main" {
  name_prefix          = "${var.identifier}-"
  launch_configuration = "${aws_launch_configuration.main.id}"
  min_size             = 0
  max_size             = 0
  vpc_zone_identifier  = ["${var.subnet_id}"]
}
