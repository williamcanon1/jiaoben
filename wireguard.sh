#! /bin/bash

apt update && apt upgrade -y

apt install wireguard -y

cd /etc/wireguard

sysctl -w net.ipv4.ip_forward=1


wg genkey | tee gw-privatekey | wg pubkey > gw-publickey

wg genkey | tee 1-privatekey | wg pubkey > 1-publickey

wg genkey | tee 2-privatekey | wg pubkey > 2-publickey

wg genkey | tee 3-privatekey | wg pubkey > 3-publickey

wg genkey | tee 4-privatekey | wg pubkey > 4-publickey

wg genkey | tee 5-privatekey | wg pubkey > 5-publickey

wg genkey | tee 6-privatekey | wg pubkey > 6-publickey

wg genkey | tee 7-privatekey | wg pubkey > 7-publickey


cat > wg0.conf <<EOF
[Interface]
ListenPort = 6666# 客户端连过来填写的端口，安全组的tcp和udp都要放行
Address = 172.19.0.1/24  #wg之前通信组网的内网ip和段
PrivateKey = $(cat gw-privatekey)   # 使用 shell 读取gateway的私钥到这里
# 下面两条是放行的iptables和MASQUERADE
PostUp   = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o ens4 -j MASQUERADE; iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o ens4 -j MASQUERADE; iptables -t nat -D POSTROUTING -o wg0 -j MASQUERADE


# pc
[Peer]
PublicKey = $(cat 1-publickey)
AllowedIPs = 172.19.0.2/32

[Peer]
PublicKey = $(cat 2-publickey)
AllowedIPs = 172.19.0.3/32

[Peer]
PublicKey = $(cat 3-publickey)
AllowedIPs = 172.19.0.4/32

[Peer]
PublicKey = $(cat 4-publickey)
AllowedIPs = 172.19.0.5/32

[Peer]
PublicKey = $(cat 5-publickey)
AllowedIPs = 172.19.0.6/32

[Peer]
PublicKey = $(cat 6-publickey)
AllowedIPs = 172.19.0.7/32

[Peer]
PublicKey = $(cat 7-publickey)
AllowedIPs = 172.19.0.8/32

EOF


cat > 1.conf <<EOF
[Interface]
PrivateKey = $(cat 1-privatekey)
Address = 172.19.0.2/24 #wg之前通信组网的内网ip和段，主机位每个得不一样
DNS = 8.8.8.8

[Peer]
PublicKey = $(cat gw-publickey)   # gateway的公钥
# pc 上访问下面的这些段都会发往 ecs 上的 wg
AllowedIPs = 0.0.0.0/0
Endpoint = $(curl -s ip.sb):6666 #gateway 公网ip和端口
PersistentKeepalive = 5 # 心跳时间
EOF

cat > 2.conf <<EOF
[Interface]
PrivateKey = $(cat 2-privatekey)
Address = 172.19.0.3/24 #wg之前通信组网的内网ip和段，主机位每个得不一样
DNS = 8.8.8.8

[Peer]
PublicKey = $(cat gw-publickey)   # gateway的公钥
# pc 上访问下面的这些段都会发往 ecs 上的 wg
AllowedIPs = 0.0.0.0/0
Endpoint = $(curl -s ip.sb):6666 #gateway 公网ip和端口
PersistentKeepalive = 5 # 心跳时间
EOF

cat > 3.conf <<EOF
[Interface]
PrivateKey = $(cat 3-privatekey)
Address = 172.19.0.4/24 #wg之前通信组网的内网ip和段，主机位每个得不一样
DNS = 8.8.8.8

[Peer]
PublicKey = $(cat gw-publickey)   # gateway的公钥
# pc 上访问下面的这些段都会发往 ecs 上的 wg
AllowedIPs = 0.0.0.0/0
Endpoint = $(curl -s ip.sb):6666 #gateway 公网ip和端口
PersistentKeepalive = 5 # 心跳时间
EOF

cat > 4.conf <<EOF
[Interface]
PrivateKey = $(cat 4-privatekey)
Address = 172.19.0.5/24 #wg之前通信组网的内网ip和段，主机位每个得不一样
DNS = 8.8.8.8

[Peer]
PublicKey = $(cat gw-publickey)   # gateway的公钥
# pc 上访问下面的这些段都会发往 ecs 上的 wg
AllowedIPs = 0.0.0.0/0
Endpoint = $(curl -s ip.sb):6666 #gateway 公网ip和端口
PersistentKeepalive = 5 # 心跳时间
EOF

cat > 5.conf <<EOF
[Interface]
PrivateKey = $(cat 5-privatekey)
Address = 172.19.0.6/24 #wg之前通信组网的内网ip和段，主机位每个得不一样
DNS = 8.8.8.8

[Peer]
PublicKey = $(cat gw-publickey)   # gateway的公钥
# pc 上访问下面的这些段都会发往 ecs 上的 wg
AllowedIPs = 0.0.0.0/0
Endpoint = $(curl -s ip.sb):6666 #gateway 公网ip和端口
PersistentKeepalive = 5 # 心跳时间
EOF

cat > 6.conf <<EOF
[Interface]
PrivateKey = $(cat 6-privatekey)
Address = 172.19.0.7/24 #wg之前通信组网的内网ip和段，主机位每个得不一样
DNS = 8.8.8.8

[Peer]
PublicKey = $(cat gw-publickey)   # gateway的公钥
# pc 上访问下面的这些段都会发往 ecs 上的 wg
AllowedIPs = 0.0.0.0/0
Endpoint = $(curl -s ip.sb):6666 #gateway 公网ip和端口
PersistentKeepalive = 5 # 心跳时间
EOF

cat > 7.conf <<EOF
[Interface]
PrivateKey = $(cat 7-privatekey)
Address = 172.19.0.8/24 #wg之前通信组网的内网ip和段，主机位每个得不一样
DNS = 8.8.8.8

[Peer]
PublicKey = $(cat gw-publickey)   # gateway的公钥
# pc 上访问下面的这些段都会发往 ecs 上的 wg
AllowedIPs = 0.0.0.0/0
Endpoint = $(curl -s ip.sb):6666 #gateway 公网ip和端口
PersistentKeepalive = 5 # 心跳时间
EOF

systemctl enable wg-quick@wg0

wg-quick up wg0
