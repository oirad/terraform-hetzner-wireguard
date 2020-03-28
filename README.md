# Terraform to create wireguard server on hetzner cloud

## WARNING

The script exposes the client configuration on port 80 on the IP, this is only intended to be used as a temporary solution to spin up a new server when needed.

If you do not want this behaviour and want to keep the server running, modify [user_data.sh](user_data.sh#L59) removing the line.

## Basic Set-up 

1. Go to https://console.hetzner.cloud/projects
2. Create a new project
3. Within the project navigate to Access > API Tokens
4. Create a new token
5. Copy the token in a file named `secrets.tfvars` which will look like
    ```
    hcloud_token = "MY_TOKEN_CONTENT_FROM_HETZNER"
    ```
6. `terraform init`
7. `terraform apply -var-file secrets.tfvars`
8. Confirm by typing `yes` when prompted
9. Wait for the process to finish, you should see an output that looks like:
    ```
    Apply complete! Resources: 1 added, 0 changed, 1 destroyed.

    Outputs:

    server_ip = 116.203.147.163
    ```
10. Open the IP (might take a little to start) and download the hetzner.conf file
11. Import this in your Wireguard client

## Advanced Set-up

### SSH Key

In case you want to access the created server copy the contents of your public ssh key (Usually stored at `~/.ssh/id_rsa.pub`) in `secrets.tfvars` adding a line that looks like:

```
ssh_key = "MY_PUBLIC_SSH_KEY_CONTENT"
```

### Server location

The default server location used is `nbg1`, you can change this by modifying `variables.tf` or add a line in `secrets.tfvars` with:

```
location = "fsn1"
```