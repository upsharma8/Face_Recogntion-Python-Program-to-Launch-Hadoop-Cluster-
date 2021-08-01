provider "aws" {

region  = "ap-south-1"
profile = "default"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0ad704c126371a549"
  instance_type = "t2.micro"
  key_name = "upkey"
  security_groups = ["upsg"]

  tags = {
    Name = "Master Node"
  }

}
output "o1"{
 value = aws_instance.app_server.public_ip
}

resource "aws_instance" "app_server1" {
  ami           = "ami-0ad704c126371a549"
  instance_type = "t2.micro"
  key_name = "upkey"
  security_groups = ["upsg"]

  tags = {
    Name = "Slave Node"
  }

}
output "o2"{
 value = aws_instance.app_server1.public_ip
}

resource "null_resource" "runcommands22" {
connection {
    type     = "ssh"
    user     = "root"
    password = "upmanyu9"
    host     = "192.168.29.186"
  }

provisioner "remote-exec" { 

    inline = [
     
      "echo [master] > ip1.txt",
      "echo ${aws_instance.app_server.public_ip} ansible_ssh_user=ec2-user ansible_ssh_private_key_file=/root/upkey.pem >> ip1.txt",
      
      "echo [slave] >> ip1.txt",
      "echo ${aws_instance.app_server1.public_ip} ansible_ssh_user=ec2-user ansible_ssh_private_key_file=/root/upkey.pem >> ip1.txt",
      "sleep 10",
      "echo '<?xml version=\"1.0\"?>' > /root/slave_files/core-site.xml",
      "echo '<?xml-stylesheet type=\"text/xsl\" href=\"configuration.xsl\"?>' >> /root/slave_files/core-site.xml",
      "echo '<!-- Put site-specific property overrides in this file. -->' >> /root/slave_files/core-site.xml",
      "echo '<configuration>' >> /root/slave_files/core-site.xml",
      "echo '<property>' >> /root/slave_files/core-site.xml",
      "echo '<name>fs.default.name</name>' >> /root/slave_files/core-site.xml",
      "echo '<value>hdfs://${aws_instance.app_server.public_ip}:9000</value>' >> /root/slave_files/core-site.xml",
      "echo '</property>' >> /root/slave_files/core-site.xml",
      "echo '</configuration>' >> /root/slave_files/core-site.xml",

      "cd /ws8/;ansible-playbook hadoop.yml",
      "cd /ws8/;ansible-playbook slave.yml"

      
    ]


 }

}