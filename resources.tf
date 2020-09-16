// create VPC
resource "aws_vpc" "velocloud-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name = "demo-vpc"
    }
}

// tags the AWS IGW
resource "aws_internet_gateway" "velo-igw" { 
    vpc_id = aws_vpc.velocloud-vpc.id
    tags = {
        Name = "demo-igw"
    }
}

// configure default route
resource "aws_route" "velo-public-rt" {
    route_table_id = aws_vpc.velocloud-vpc.main_route_table_id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.velo-igw.id
}

// define public subnet
resource "aws_subnet" "velo-public-sn" {
    vpc_id = aws_vpc.velocloud-vpc.id 
    cidr_block = var.public_sn_cidr_block 
    availability_zone = var.aws_availability_zone 
    map_public_ip_on_launch = false
    tags = {
        Name = "demo-public-sn"
        }
}

// define private subnet
resource "aws_subnet" "velo-private-sn" {
    vpc_id = aws_vpc.velocloud-vpc.id 
    cidr_block = var.private_sn_cidr_block
    availability_zone = var.aws_availability_zone
    map_public_ip_on_launch = false
    tags = {
        Name = "demo-private-sn"
    }
}

// define security group for LAN interface
resource "aws_security_group" "velo-sg-lan" {
    vpc_id = aws_vpc.velocloud-vpc.id
    tags = {
        Name = "demo-sg-lan"
    }
    // ALL
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    // ALL
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

// define security group for WAN interface
resource "aws_security_group" "velo-sg-wan" {
    vpc_id = aws_vpc.velocloud-vpc.id
    tags = {
        Name = "demo-sg-wan"
    }
    // SSH
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    // VCMP
    ingress {
        from_port = 2426
        to_port = 2426
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    // ALL
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

// GE1 definition - Management interface
resource "aws_network_interface" "velo-ge1" { 
    subnet_id = aws_subnet.velo-public-sn.id 
    source_dest_check = false
    security_groups = [aws_security_group.velo-sg-wan.id]
}

// GE2 definition - WAN interface
resource "aws_network_interface" "velo-ge2" { 
    subnet_id = aws_subnet.velo-public-sn.id 
    source_dest_check = false
    security_groups = [aws_security_group.velo-sg-wan.id]
}

// GE3 definition - LAN interface
resource "aws_network_interface" "velo-ge3" { 
    subnet_id = aws_subnet.velo-private-sn.id 
    private_ips = [var.private_ip]
    source_dest_check = false
    security_groups = [aws_security_group.velo-sg-lan.id]
}

// key pair creation
resource "tls_private_key" "velo-key" {
  algorithm = "RSA"
}

module "key_pair" {
  source = "terraform-aws-modules/key-pair/aws"
  public_key = tls_private_key.velo-key.public_key_openssh
  key_name = var.key_name
}

// VCE creation
resource "aws_instance" "velo-instance" { 
    instance_type = var.instance_type
    key_name = var.key_name
    ami = lookup(var.aws_amis, var.aws_region)
    user_data = file("cloud-init")
    network_interface {
        network_interface_id = aws_network_interface.velo-ge1.id
        device_index  = 0
    }
    network_interface {
        network_interface_id = aws_network_interface.velo-ge2.id 
        device_index = 1
    }
    network_interface {
        network_interface_id = aws_network_interface.velo-ge3.id 
        device_index = 2
        }
    tags = {
        Name = "vce"
    }
}

// Elastic IP creation for WAN
resource "aws_eip" "velo-ge2-eip" {
    network_interface = aws_network_interface.velo-ge2.id
    vpc = true
    depends_on = [aws_instance.velo-instance]
    tags = {
        Name = "velo-ge2-eip"
    }
}

// Static route for branch (example)
resource "aws_route" "branch_route" {
    route_table_id = aws_vpc.velocloud-vpc.main_route_table_id
    depends_on = [aws_instance.velo-instance, aws_network_interface.velo-ge3]
    destination_cidr_block = "10.5.99.0/24"
    network_interface_id = aws_network_interface.velo-ge3.id
}
