provider "aws" {
    region = "us-west-2"
}

variable "key_name" {
    type = "string"
    default = "container_camp_zero"
}

module "vpc" {
    source = "modules/vpc"

    name = "Production"
    cidr = "10.0.0.0/16"
    private_subnets = "10.0.160.0/19,10.0.192.0/19"
    public_subnets = "10.0.0.0/21,10.0.8.0/21"
    availability_zones = "us-west-2a,us-west-2b"
}

module "vpn" {
    source = "modules/vpn"

    vpc_id = "${module.vpc.vpc_id}"
    public_subnets = "${module.vpc.public_subnets}"
    key_name = "${var.key_name}"
}

module "consul" {
    source = "modules/consul"

    cluster_name = "Production"

    vpc_id = "${module.vpc.vpc_id}"
    subnets = "${module.vpc.private_subnets}"
    ingress_cidr_blocks = "0.0.0.0/0"

    key_name = "${var.key_name}"
    ami = "ami-7544b315"
    instance_type = "t2.micro"
}

output "vpn_ip" {
    value = "${module.vpn.vpn_ip}"
}

output "vpn_setup" {
    value = "ssh openvpnas@${module.vpn.vpn_ip}"
}

output "vpn_login" {
    value = "https://${module.vpn.vpn_ip}:943"
}
