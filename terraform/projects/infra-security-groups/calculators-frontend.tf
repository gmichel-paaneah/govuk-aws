#
# == Manifest: Project: Security Groups: calculators-frontend
#
# The calculators-frontend needs to be accessible on ports:
#   - 443 from the other VMs
#
# === Variables:
# stackname - string
#
# === Outputs:
# sg_calculators-frontend_id
# sg_calculators-frontend_elb_id

resource "aws_security_group" "calculators-frontend" {
  name        = "${var.stackname}_calculators-frontend_access"
  vpc_id      = "${data.terraform_remote_state.infra_vpc.vpc_id}"
  description = "Access to the calculators-frontend host from its ELB"

  tags {
    Name = "${var.stackname}_calculators-frontend_access"
  }
}

resource "aws_security_group_rule" "allow_calculators-frontend_elb_in" {
  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  # Which security group is the rule assigned to
  security_group_id = "${aws_security_group.calculators-frontend.id}"

  # Which security group can use this rule
  source_security_group_id = "${aws_security_group.calculators-frontend_elb.id}"
}

resource "aws_security_group" "calculators-frontend_elb" {
  name        = "${var.stackname}_calculators-frontend_elb_access"
  vpc_id      = "${data.terraform_remote_state.infra_vpc.vpc_id}"
  description = "Access the calculators-frontend ELB"

  tags {
    Name = "${var.stackname}_calculators-frontend_elb_access"
  }
}

# TODO: replace this with ingress from the frontend LBs when we build them.
resource "aws_security_group_rule" "allow_management_to_calculators-frontend_elb" {
  type      = "ingress"
  from_port = 443
  to_port   = 443
  protocol  = "tcp"

  security_group_id        = "${aws_security_group.calculators-frontend_elb.id}"
  source_security_group_id = "${aws_security_group.management.id}"
}

# TODO test whether egress rules are needed on ELBs
resource "aws_security_group_rule" "allow_calculators-frontend_elb_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.calculators-frontend_elb.id}"
}
