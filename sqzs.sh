#!/bin/bash

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
mkdir /root/ssl
acme.sh --installcert -d $website --ecc  --key-file   /root/ssl/server.key   --fullchain-file  /root/ssl/server.crt 
