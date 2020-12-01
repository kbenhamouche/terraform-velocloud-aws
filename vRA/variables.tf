// AWS variables
variable "aws_region" {
  description = "Enter your region (example: ca-central-1 for Canada Central)"
  default = "ca-central-1"
}

variable "aws_availability_zone" {
  description = "Enter your AWS availability zone (example: ca-central-1a for Canada Central)"
  default = "ca-central-1a"
}

variable "key_name" {
  description = "Enter a desired name for the AWS key pair (example: vce)"
  default = "vce"
}

variable "vpc_cidr_block" {
  description = "Enter the VPC subnet (example: 172.16.0.0/16)"
  default = "172.16.0.0/16"
}

variable "public_sn_cidr_block" {
  description = "Enter the public subnet (example: 172.16.0.0/24)"
  default = "172.16.0.0/24"
}

variable "private_sn_cidr_block" {
  description = "Enter the private subnet (example: 172.16.100.0/24)"
  default = "172.16.100.0/24"
}

variable "private_ip" {
  description = "Enter the private IP for the LAN interface (example: 172.16.100.100) - this IP has to be configured in VCO/Edge/Device as Corporate IP"
  default = "172.16.100.100"
}

variable "instance_type" {
  description = "Enter the instance type (example: c4.large)"
  default = "c4.large"
}

# VeloCloud SD-WAN vEdge (3.3.1)
variable "aws_amis" {
    default = {
        eu-north-1 = "ami-ba9c16c4"
        ap-south-1 = "ami-08df28503c779c65b"
        eu-west-3 = "ami-00bb1d7d48dd45aac"
        eu-west-2 = "ami-0910c04a99eda46f3"
        eu-west-1 = "ami-0f5a1ddf49df24d29"
        ap-northeast-2 = "ami-001c1e312fec38b26"
        ap-northeast-1 = "ami-02028fdfda2bedef3"
        sa-east-1 = "ami-03476bb22664d682d"
        ca-central-1 = "ami-03a3ed427dd6af221"
        ap-southeast-1 = "ami-00b0ac7201061dce6"
        ap-southeast-2 = "ami-0b7196fd587231352"
        eu-central-1 = "ami-0e3ef4a959a447466"
        us-east-1 = "ami-0a9373a4b23e149b7"
        us-east-2 = "ami-00009cd364607db91"
        us-west-1 = "ami-0eae7918e6c5e03e3"
        us-west-2 = "ami-0e2374b672d5149c3"
    }
}

