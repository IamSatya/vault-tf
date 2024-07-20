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