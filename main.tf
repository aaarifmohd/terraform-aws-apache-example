
data "aws_ami" "RHEL" {
  most_recent = true

  filter {
    name   = "name"
    values = ["RHEL-9*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["309956199498"] # Canonical
}


data "aws_vpc" "main" {
    id = var.vpc_id
}

data "template_file" "user_data" {
    template = file("${abspath(path.module)}/userdata.yml")
}
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDSjxcCng8tfUL7c8P0mheyAlyQZ8o9y26Axn7UFWFYADiJZ/Gly5HmuwYQRv67Cogar/h6HP8Ztk5QHjqvyhk0Gfav5db2GSBr2iic8JW0yAMYYiGBiwBeUUJPxla8gywvBZxTi3NIMQvifeXaUqybJdAvbzCaVtUhwsht3Ybby8jmPiByaSrgIvR2IxPUG/Vd+nv+Sw4/Goh45tnANMA/sm0Un/a06mb31tyf+0otni9s/jXA/0VBOvA3e0aBb5nwl+10zKFBPSx8pE3huQOnfclGjaYmf76KpF/0fcn1kKUa+qr14wAZaLb9VQ21VblhriBRNceD44Lkxri1gq61wKa4DMWVaTZgQ96b7Q4hKwlWPpFuxfNTCmOgyjS5uxBCr7fFyWfamI24Bn7hkwWysFhWh5mus5Gjiez8AcTyfvhRqz6ZprlbEXa4nc0ISMeTUWtr54CWL7i4M0Nd4cEmqH15lL5+evdM7NLtXoHHJD+RliNf30v555tPcDTnvXc="
}

resource "aws_security_group" "cloud-init-sg" {
  name        = "cloud-init-sg"
  description = "Allow Apache inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.main.id

  ingress = [
    {
        description = "HTTP"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["{var.my_ip}/32"]
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        security_groups = []
        self = false
    },
    {
        description = "HTTPs"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["{var.my_ip}/32"]
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        security_groups = []
        self = false
    },
    {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["{var.my_ip}/32"]
        ipv6_cidr_blocks = []
        prefix_list_ids = []
        security_groups = []
        self = false
    }
  ]
  egress = [
    {
    description = "outgoing traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids = []
    security_groups = []
    self = false
   }
  ]
  tags = {
    Name = "cloud-init-sg"
  }
}


resource "aws_instance" "my-server" {
    ami = data.aws_ami.RHEL.id
    instance_type = "t2.micro"
    key_name = "${aws_key_pair.deployer.key_name}"
    user_data = data.template_file.user_data.rendered
    vpc_security_group_ids = [aws_security_group.cloud-init-sg.id]

    tags = {
      Name = "cloud-module-server"
    }
    #test
}