resource "aws_key_pair" "vaultkey" {
  key_name = "vaultkey"
  public_key = file("/root/.ssh/awskey.pub") 
}

resource "aws_instance" "vault" {
  ami = "ami-04a81a99f5ec58529"
  instance_type = "t3.micro"
  key_name = "vaultkey"
  vpc_security_group_ids = [aws_security_group.ssh.id]

  connection {
    type = "ssh"
    user = "ubuntu"
    private_key = file("/root/.ssh/awskey")
    host = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [ 
        "sudo apt update && sudo apt install gpg -y",
        "wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg",
        "gpg --no-default-keyring --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg --fingerprint",
        "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main\" | sudo tee /etc/apt/sources.list.d/hashicorp.list",
        "sudo apt update",
        "sudo apt install vault -y",
        "vault server -dev -dev-listen-address=\"0.0.0.0:8200\" & > ~/vault.out"
     ]
    }
    depends_on = [ aws_key_pair.vaultkey, aws_security_group.ssh ]
}