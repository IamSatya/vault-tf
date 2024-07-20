provider "vault" {
  address = "http://54.91.189.58:8200"
  skip_child_token = true
  auth_login {
    path = "auth/approle/login"

    parameters = {
        role_id = "caf0e394-2173-eaae-a8e2-11d1097ff07b"
        secret_id = "7f08304d-9cf7-308d-83a3-af99f70df948"
    }
  }
}

data "vault_kv_secret_v2" "admin" {
    mount = "kv"
    name = "admincreds"
}

resource "aws_instance" "app" {
  ami = "ami-04a81a99f5ec58529"
  instance_type = "t3.micro"
  key_name = "vaultkey"
  vpc_security_group_ids = [aws_security_group.ssh.id]

  tags = {
    Name = "APPServer"
    Admin = data.vault_kv_secret_v2.admin.admin
  }

}