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
read  -e -p "输入安装路径" Luji
if [ -e $Luji ];then
        echo 文件存在
else
        mkdir -p $Luji
fi
acme.sh --installcert -d $website --ecc  --key-file   $Luji/server.key   --fullchain-file  $Luji/server.crt 
