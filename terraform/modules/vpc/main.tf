variable "name" {}
variable "cidr" {}
variable "public_subnets" {}
variable "private_subnets" {}
variable "availability_zones" {}

resource "aws_vpc" "vpc" {
    cidr_block = "${var.cidr}"

    tags {
        Name = "${format("%s", var.name)}"
    }
}

resource "aws_subnet" "private" {
    count = "${length(split(",", var.private_subnets))}"

    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${element(split(",", var.private_subnets), count.index)}"
    availability_zone = "${element(split(",", var.availability_zones), count.index)}"
    
    tags {
        Name = "${format("%s Private %d", var.name, count.index + 1)}"
        network = "private"
    }
}

resource "aws_subnet" "public" {
    count = "${length(split(",", var.public_subnets))}"

    vpc_id = "${aws_vpc.vpc.id}"
    cidr_block = "${element(split(",", var.public_subnets), count.index)}"
    availability_zone = "${element(split(",", var.availability_zones), count.index)}"
    map_public_ip_on_launch = true
    
    tags {
        Name = "${format("%s Public %d", var.name, count.index + 1)}"
    }
}

resource "aws_internet_gateway" "vpc" {
    vpc_id = "${aws_vpc.vpc.id}"
    
    tags {
        Name = "${format("%s Gateway", var.name)}"
    }
}

resource "aws_route_table" "private" {
    count = "${length(split(",", var.private_subnets))}"
    vpc_id = "${aws_vpc.vpc.id}"

    tags {
        Name = "${format("%s Private", var.name)}"
    }
}

resource "aws_route_table_association" "private" {
    count = "${length(split(",", var.private_subnets))}"

    subnet_id = "${element(aws_subnet.private.*.id, count.index)}"
    route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_route_table" "public" {
    vpc_id = "${aws_vpc.vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.vpc.id}"
    }

    tags {
        Name = "${format("%s Public", var.name)}"
    }
}

resource "aws_route_table_association" "public" {
    count = "${length(split(",", var.public_subnets))}"

    subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
    route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route" "nat_routes" {
    count = "${length(split(",", var.private_subnets))}"
    destination_cidr_block = "0.0.0.0/0"

    route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
    nat_gateway_id = "${element(aws_nat_gateway.private.*.id, count.index)}"
}

resource "aws_eip" "nat_eip" {
    count = "${length(split(",", var.private_subnets))}"
    vpc = true
}

resource "aws_nat_gateway" "private" {
    count = "${length(split(",", var.private_subnets))}"

    allocation_id = "${element(aws_eip.nat_eip.*.id, count.index)}"
    subnet_id = "${element(aws_subnet.public.*.id, count.index)}"
}

output "private_subnets" {
    value = "${join(",", aws_subnet.private.*.id)}"
}

output "public_subnets" {
    value = "${join(",", aws_subnet.public.*.id)}"
}

output "private_availability_zones" {
    value = "${join(",", aws_subnet.private.*.availability_zone)}"
}

output "public_availability_zones" {
    value = "${join(",", aws_subnet.public.*.availability_zone)}"
}

output "name" {
    value = "${var.name}"
}

output "vpc_id" {
    value = "${aws_vpc.vpc.id}"
}

output "cidr_block" {
    value = "${aws_vpc.vpc.cidr_block}"
}
