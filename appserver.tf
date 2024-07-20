provider "vault" {
  address = "http://54.91.189.58:8200"
  skip_child_token = true
  auth_login {
    path = "auth/approle/login"

    parameters = {
        role_id = "env://vault_role_id"
        secret_id = "env://vault_secret_id"
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
    Admin = data.vault_kv_secret_v2.admin.data["admin"]
  }

}