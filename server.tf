resource "hcloud_ssh_key" "access" {
  name       = "access"
  public_key = file(var.ssh_key_location)
}

resource "hcloud_server" "wireguard" {
  name        = "wireguard"
  image       = "debian-10"
  server_type = "cx11"
  location    = var.location
  user_data   = file("user_data.sh")
  ssh_keys    = [hcloud_ssh_key.access.id]

  labels = local.labels
}