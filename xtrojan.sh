#!/bin/bash
apt update && apt upgrade -y

echo 部署开机配置

sleep 1

mkdir /root/xray
cd /root/xray

cat /lib/systemd/system/xtrojan.service << EOF 
[Unit]
Description=xTrojan
After=network.target nss-lookup.target

[Service]
Type=simple
ExecStart=/root/xray/xray -c /root/xray/config.json
ExecReload=/bin/kill -HUP
Restart=on-failure
RestartSec=10s
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
EOF

###########################################################
echo 下载文件

apt install wget unzip -y

banben=./banben

wget -qO- -t1 -T2 "https://api.github.com/repos/XTLS/Xray-core/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g' > $banben

wget "https://github.com/XTLS/Xray-core/releases/download/$(cat $banben)/Xray-linux-64.zip"

rm -rf $banben

unzip Xray-*
###########################################################
read -p "输入转发地址 需要携带https://的完整地址"  zhuanfa
read -p "输入端口 可随机"  Duankou
read -p "输入路径"  Lujing
read -p "输入密码"  Mimaa
read -p "输入域名"  Yuming

cat > /root/xray/config.json << EOF
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": "$Duankou",
      "protocol": "trojan",
      "settings": {
        "clients": [
          {
            "password": "$Mimaa"
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/$Lujing"
        }
      }
    }
  ],
  "outbounds": [
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {}
    },
    {
      "tag": "blocked",
      "protocol": "blackhole",
      "settings": {}
    }
  ],
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      {
        "type": "field",
        "ip": [
          "geoip:private"
        ],
        "outboundTag": "blocked"
      }
    ]
  }
}
EOF
systemctl start xtrojan.service && systemctl enable xtrojan.service
apt install nginx -y
cat > /etc/nginx/conf.d/default.conf << EOF

server{
   listen 80;
   server_name   $Yuming ;
   if ($host ~* "$Yuming$") {
   rewrite ^/(.*)$ https://$Yuming/ permanent;
}
}
server {
    listen 443 ssl http2;
    server_name   $Yuming;

    ssl_certificate /home/william/.ssl/server.crt;
    ssl_certificate_key /home/william/.ssl/server.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers TLS13_AES_128_GCM_SHA256:TLS13_AES_256_GCM_SHA384:TLS13_CHACHA20_POLY1305_SHA256:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305;

   location /$Lujing {
        if ($http_upgrade != "websocket") {
                return 404;
        }
        proxy_pass http://127.0.0.1:$Duankou;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_read_timeout 52w;
}
    location / {
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-Proto $scheme;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_pass $zhuanfa;
}
}
EOF
nginx -s reload

