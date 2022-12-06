#! /bin/bash

apt update && apt upgrade -y

apt install wireguard net-tools  -y

cd /etc/wireguard

sysctl -w net.ipv4.ip_forward=1


wg genkey | tee gw-privatekey | wg pubkey > gw-publickey

for a in 1 2 3 4 5 6 7
do
        wg genkey | tee $a-privatekey | wg pubkey > $a-publickey
done

ovrn=`ifconfig | grep flags| head -n 1 | awk -F ":" '{print $1}'`
cat > wg0.conf <<EOF
[Interface]
ListenPort = 6666# 客户端连过来填写的端口，安全组的tcp和udp都要放行
Address = 172.19.0.1/24  #wg之前通信组网的内网ip和段
PrivateKey = $(cat gw-privatekey)   # 使用 shell 读取gateway的私钥到这里
# 下面两条是放行的iptables和MASQUERADE
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o $ovrn -j MASQUERADE; iptables -t nat -A POSTROUTING -o wg0 -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o $ovrn -j MASQUERADE; iptables -t nat -D POSTROUTING -o wg0 -j MASQUERADE

EOF
for c in 1 2 3 4 5 6 7
do
b=`expr $c + 1`
cat >> wg0.conf <<EOF
[Peer]
PublicKey = $(cat $c-publickey)
AllowedIPs = 172.19.0.$b/32
EOF
done


for d in 1 2 3 4 5 6 7
do
e=`expr $d + 1`
cat > $d.conf <<EOF
[Interface]
PrivateKey = $(cat $d-privatekey)
Address = 172.19.0.$e/24 #wg之前通信组网的内网ip和段，主机位每个得不一样
DNS = 8.8.8.8

[Peer]
PublicKey = $(cat gw-publickey)   # gateway的公钥
# pc 上访问下面的这些段都会发往 ecs 上的 wg
AllowedIPs = 0.0.0.0/0
Endpoint = $(curl -s4 ip.sb):6666 #gateway 公网ip和端口
PersistentKeepalive = 5 # 心跳时间
EOF
done
ufw allow 6666
systemctl enable wg-quick@wg0

wg-quick up wg0
