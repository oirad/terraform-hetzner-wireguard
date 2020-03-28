#!/bin/sh

echo "deb http://deb.debian.org/debian/ unstable main" > /etc/apt/sources.list.d/unstable-wireguard.list
printf 'Package: *\nPin: release a=unstable\nPin-Priority: 150\n' > /etc/apt/preferences.d/limit-unstable
apt-get update

apt-get install -y linux-headers-$(uname -r)

apt-get update
apt-get install -y wireguard-dkms wireguard-tools

wg genkey | tee /etc/wireguard/wg-private.key | wg pubkey > /etc/wireguard/wg-public.key
wg genkey | tee /root/client.key | wg pubkey > /root/client.pub

S_PRIKEY=$(cat /etc/wireguard/wg-private.key)
S_PUBKEY=$(cat /etc/wireguard/wg-public.key)
C_PRIKEY=$(cat /root/client.key)
C_PUBKEY=$(cat /root/client.pub)
IP=$(curl -4 https://icanhazip.com/)

cat <<EOL > /etc/wireguard/wg0.conf
[Interface]
Address = 10.0.0.1/24
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; ip6tables -A FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE; ip6tables -D FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
SaveConfig = true
ListenPort = 56
PrivateKey = $S_PRIKEY

[Peer]
PublicKey = $C_PUBKEY
AllowedIPs = 10.0.0.0/24, 10.0.0.2/32
PersistentKeepalive = 25
EOL

cat <<EOL > /root/client.conf
[Interface]
Address = 10.0.0.2/32
PrivateKey = $C_PRIKEY
DNS = 1.1.1.1

[Peer]
PublicKey = $S_PUBKEY
AllowedIPs = 0.0.0.0/0, ::/0
Endpoint = $IP:56
PersistentKeepalive = 25
EOL

echo 1 > /proc/sys/net/ipv4/ip_forward
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

systemctl enable wg-quick@wg0
systemctl start wg-quick@wg0

mkdir /root/conf/
cd /root/conf
cp /root/client.conf hetzner.conf

python3 -m http.server 80