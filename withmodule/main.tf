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
  default = "matschaffer-test2"
}

variable "subnet_id" {
  description = "Specified using TF_VAR_subnet_id to keep account IDs out of github issue"
}

module "shared" {
  source     = "shared"
  identifier = "${var.identifier}"
  image_id   = "${data.aws_ami.xenial.id}"
}

resource "aws_autoscaling_group" "main" {
  name_prefix          = "${var.identifier}-"
  launch_configuration = "${module.shared.launch_configuration_id}"
  min_size             = 0
  max_size             = 0
  vpc_zone_identifier  = ["${var.subnet_id}"]
}
