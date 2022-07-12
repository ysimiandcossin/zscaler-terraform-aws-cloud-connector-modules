data "aws_vpc" "selected" {
  id = var.vpc
}

# Create Security Group for CC Management Interface
resource "aws_security_group" "cc-mgmt-sg" {
  count       = var.byo_security_group == false ? var.sg_count : 0
  name        = var.sg_count > 1 ? "${var.name_prefix}-cc-${count.index + 1}-mgmt-sg-${var.resource_tag}" : "${var.name_prefix}-cc-mgmt-sg-${var.resource_tag}"
  description = "Security group for Cloud Connector management interface"
  vpc_id      = var.vpc

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.global_tags,
        { Name = "${var.name_prefix}-cc-mgmt-sg-${var.resource_tag}" }
  )
}

resource "aws_security_group_rule" "cc-mgmt-ingress-ssh" {
  count             = var.byo_security_group == false ? var.sg_count : 0
  description       = "Allow SSH to Cloud Connector VM"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.cc-mgmt-sg.*.id[count.index]
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
  type              = "ingress"
}

# Create Security Group for Service Interface
resource "aws_security_group" "cc-service-sg" {
  count       = var.byo_security_group == false ? var.sg_count : 0
  name        = var.sg_count > 1 ? "${var.name_prefix}-cc-${count.index + 1}-svc-sg-${var.resource_tag}" : "${var.name_prefix}-cc-svc-sg-${var.resource_tag}"
  description = "Security group for Cloud Connector service interfaces"
  vpc_id      = var.vpc

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.global_tags,
        { Name = "${var.name_prefix}-cc-svc-sg-${var.resource_tag}" }
  )
}

resource "aws_security_group_rule" "all-vpc-ingress-cc" {
  count             = var.byo_security_group == false ? var.sg_count : 0
  description       = "Allow all VPC traffic"
  from_port         = 0
  to_port           = 65535
  protocol          = "-1"
  security_group_id = aws_security_group.cc-service-sg.*.id[count.index]
  cidr_blocks       = ["0.0.0.0/0"]
  type              = "ingress"
}