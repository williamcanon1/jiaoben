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


#!/bin/bash

echo 开启bbr
sleep 2

echo "net.core.default_qdisc=fq" >> /etc/sysctl.conf
echo "net.ipv4.tcp_congestion_control=bbr" >> /etc/sysctl.conf
sysctl -p

echo 部署开机配置

sleep 1

mkdir /root/trojan
cd /root/trojan

cat > trojan.service << EOF
[Unit]
Description=Trojan - An unidentifiable mechanism that helps you bypass GFW
Documentation=https://p4gefau1t.github.io/trojan-go/
After=network.target nss-lookup.target

[Service]
Type=simple
PIDFile=/root/trojan/trojan-go.pid
ExecStart=/root/trojan/trojan-go -config /root/trojan/server.json
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=10s
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
EOF


mv trojan.service /lib/systemd/system/
###########################################################
echo 下载文件

apt install wget unzip -y

banben=./banben

wget -qO- -t1 -T2 "https://api.github.com/repos/p4gefau1t/trojan-go/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g' > $banben

wget "https://github.com/p4gefau1t/trojan-go/releases/download/$(cat $banben)/trojan-go-linux-amd64.zip"

rm -rf $banben

unzip trojan-go-linux-amd64.zip
###########################################################
echo 申请证书

apt update && apt upgrade -y

curl https://get.acme.sh | sh #安装acme
apt install socat  #安装socat

ln -s  /root/.acme.sh/acme.sh /usr/local/bin/acme.sh
acme.sh --register-account -m my@example.com
ufw allow 80
acme.sh --set-default-ca --server letsencrypt
read -p "输入域名" website

acme.sh  --issue -d $website  --standalone -k ec-256

echo 安装证书 
acme.sh --installcert -d $website --ecc  --key-file   /root/trojan/server.key   --fullchain-file  /root/trojan/server.crt 

###############################################################
echo 部署json

read -p "输入转发地址" zhuanfa
cat > server.json << EOF
{
    "run_type": "server",
    "local_addr": "0.0.0.0",
    "local_port": 443,
    "remote_addr": "$zhuanfa",
    "remote_port": 80,
    "password": [
        "william202016"
    ],
    "log_level": 1,
    "log_file": "/root/trojan-go-access.log",
    "ssl": {
        "verify": true,
        "verify_hostname": true,
        "cert": "/root/trojan/server.crt",
        "key": "/root/trojan/server.key",
        "sni": "$website",
        "fallback_addr": "$zhuanfa",
        "fallback_port": 80,
        "fingerprint": "chrome"
    },
    "websocket": {
        "enabled": true,
        "path": "/a777d82d",
        "host": "$website"
    }
}

EOF

apt install nginx -y

host='$host'
cat > /etc/nginx/conf.d/default.conf << EOF
server{
   listen 80;
   server_name   $website;
   #把http的域名请求转成https
#   rewrite ^(.*)$ https://$host$1; #将所有HTTP请求通过rewrite指令重定向到HTTPS。
   if ($host ~* "wica.top$") {
   rewrite ^/(.*)$ https://$website/ permanent;
}
}
EOF

systemctl restart nginx 

systemctl enable trojan && systemctl start trojan

read -p "输入自建前辍" qianzhui
echo url:trojan://william202016@$website:443?peer=$website&sni=$website"#"$qianzhui_自建


ufw allow 443/tcp 
ufw allow 80/tcp
ufw allow 1997/tcp
ufw allow 22/tcp
ufw allow 6666
